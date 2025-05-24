import 'package:raw_material_management/core/error/failures.dart';
import 'package:raw_material_management/core/network/network_info.dart';
import 'package:raw_material_management/core/services/google_sheets_service.dart';
import 'package:raw_material_management/core/services/hive_service.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';
import 'package:raw_material_management/features/manufacturing/domain/repositories/manufacturing_log_repository.dart';
import 'package:uuid/uuid.dart';

class ManufacturingLogRepositoryImpl implements ManufacturingLogRepository {
  final HiveService<ManufacturingLogModel> _hiveService;
  final GoogleSheetsService _sheetsService;
  final NetworkInfo _networkInfo;

  ManufacturingLogRepositoryImpl({
    required HiveService<ManufacturingLogModel> hiveService,
    required GoogleSheetsService sheetsService,
    required NetworkInfo networkInfo,
  })  : _hiveService = hiveService,
        _sheetsService = sheetsService,
        _networkInfo = networkInfo;

  // Helper method to format UUID for Google Sheets
  String _formatUuidForSheets(String uuid) {
    // Remove hyphens and convert to uppercase for better readability
    return uuid.replaceAll('-', '').toUpperCase();
  }

  // Helper method to parse UUID from Google Sheets format
  String _parseUuidFromSheets(String formattedUuid) {
    // Convert back to lowercase and add hyphens
    final uuid = formattedUuid.toLowerCase();
    return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}';
  }

  // Helper method to format materials for Google Sheets
  String _formatMaterialsForSheets(List<MaterialUsage> materials) {
    return materials.map((m) => 
      '${m.materialName} (${m.quantity} ${m.unit})'
    ).join(' | ');
  }

  // Helper method to parse materials from Google Sheets format
  List<MaterialUsage> _parseMaterialsFromSheets(String formattedMaterials) {
    final materialStrings = formattedMaterials.split(' | ');
    return materialStrings.map((str) {
      // Extract material name, quantity, and unit from the string
      // Format: "Material Name (quantity unit)"
      final match = RegExp(r'(.+?)\s*\((\d+\.?\d*)\s*(\w+)\)').firstMatch(str);
      if (match != null) {
        final materialName = match.group(1)?.trim() ?? '';
        final quantity = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        final unit = match.group(3)?.trim() ?? '';
        
        return MaterialUsage(
          materialId: '', // We don't store materialId in sheets
          materialName: materialName,
          quantity: quantity,
          unit: unit,
        );
      }
      return MaterialUsage(
        materialId: '',
        materialName: str,
        quantity: 0,
        unit: '',
      );
    }).toList();
  }

  @override
  Future<List<ManufacturingLogModel>> getAllLogs() async {
    return _hiveService.getAll();
  }

  @override
  Future<ManufacturingLogModel?> getLogById(String id) async {
    return _hiveService.get(id);
  }

  @override
  Future<void> addLog(ManufacturingLogModel log) async {
    final newLog = log.copyWith(
      id: const Uuid().v4(),
      manufacturedAt: DateTime.now(),
    );

    await _hiveService.add(newLog);

    if (await _networkInfo.isConnected) {
      try {
        // Format the log for Google Sheets
        final values = [
          _formatUuidForSheets(newLog.id),
          newLog.productName,
          newLog.quantity.toString(),
          _formatMaterialsForSheets(newLog.materialsUsed),
          newLog.manufacturedAt.toIso8601String(),
          newLog.notes ?? '',
        ];

        await _sheetsService.appendSheetData(
          'manufacturing_logs!A:F',
          [values],
        );
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync manufacturing log with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> updateLog(ManufacturingLogModel log) async {
    // First delete the old log from Hive
    await _hiveService.delete(log.id);
    // Then add the updated log
    await _hiveService.add(log);

    if (await _networkInfo.isConnected) {
      try {
        // Get all logs to find the row index of the log to update
        final sheetData = await _sheetsService.getSheetData('manufacturing_logs!A:A');
        final rowIndex = sheetData.indexWhere((row) => 
          _parseUuidFromSheets(row[0]) == log.id
        );

        if (rowIndex == -1) {
          throw ServerFailure(
            message: 'Log not found in Google Sheets',
            code: 'LOG_NOT_FOUND',
          );
        }

        // Format the log for Google Sheets
        final values = [
          _formatUuidForSheets(log.id),
          log.productName,
          log.quantity.toString(),
          _formatMaterialsForSheets(log.materialsUsed),
          log.manufacturedAt.toIso8601String(),
          log.notes ?? '',
        ];

        // Update the specific row in Google Sheets
        await _sheetsService.updateSheetData(
          'manufacturing_logs!A${rowIndex + 1}:F${rowIndex + 1}',
          [values],
        );
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync manufacturing log with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> deleteLog(String id) async {
    await _hiveService.delete(id);

    if (await _networkInfo.isConnected) {
      try {
        final allLogs = await _hiveService.getAll();
        final values = allLogs.map((l) => [
          _formatUuidForSheets(l.id),
          l.productName,
          l.quantity.toString(),
          _formatMaterialsForSheets(l.materialsUsed),
          l.manufacturedAt.toIso8601String(),
          l.notes ?? '',
        ]).toList();
        await _sheetsService.updateSheetData('manufacturing_logs!A:F', values);
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync manufacturing log with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> syncWithGoogleSheets() async {
    if (!await _networkInfo.isConnected) {
      throw NetworkFailure(
        message: 'No internet connection available',
      );
    }

    try {
      final sheetData = await _sheetsService.getSheetData('manufacturing_logs!A:F');
      final logs = sheetData.map((row) {
        return ManufacturingLogModel(
          id: _parseUuidFromSheets(row[0]),
          productName: row[1],
          quantity: int.parse(row[2]),
          materialsUsed: _parseMaterialsFromSheets(row[3]),
          manufacturedAt: DateTime.parse(row[4]),
          notes: row[5].isEmpty ? null : row[5],
        );
      }).toList();

      await _hiveService.clear();
      for (final log in logs) {
        await _hiveService.add(log);
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to sync with Google Sheets',
        code: e.toString(),
      );
    }
  }

  @override
  Stream<List<ManufacturingLogModel>> watchLogs() {
    return _hiveService.watchAll();
  }

  @override
  Future<List<ManufacturingLogModel>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final logs = await _hiveService.getAll();
    return logs.where((log) {
      return log.manufacturedAt.isAfter(start) && log.manufacturedAt.isBefore(end);
    }).toList();
  }
} 