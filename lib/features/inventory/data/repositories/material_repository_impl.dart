import 'package:raw_material_management/core/error/failures.dart';
import 'package:raw_material_management/core/network/network_info.dart';
import 'package:raw_material_management/core/services/google_sheets_service.dart';
import 'package:raw_material_management/core/services/hive_service.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/inventory/domain/repositories/material_repository.dart';
import 'package:uuid/uuid.dart';

class MaterialRepositoryImpl implements MaterialRepository {
  final HiveService<MaterialModel> _hiveService;
  final GoogleSheetsService _sheetsService;
  final NetworkInfo _networkInfo;

  MaterialRepositoryImpl({
    required HiveService<MaterialModel> hiveService,
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

  @override
  Future<List<MaterialModel>> getAllMaterials() async {
    return _hiveService.getAll();
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async {
    return _hiveService.get(id);
  }

  @override
  Future<void> addMaterial(MaterialModel material) async {
    final newMaterial = material.copyWith(
      id: const Uuid().v4(),
      lastUpdated: DateTime.now(),
    );

    await _hiveService.add(newMaterial);

    if (await _networkInfo.isConnected) {
      try {
        // Create a copy of the material with formatted UUID for Google Sheets
        final sheetMaterial = newMaterial.copyWith(
          id: _formatUuidForSheets(newMaterial.id),
        );
        
        await _sheetsService.appendSheetData(
          'inventory_sheet!A1:F1',
          [sheetMaterial.toJson().values.toList()],
        );
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync material with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> updateMaterial(MaterialModel material) async {
    final updatedMaterial = material.copyWith(
      lastUpdated: DateTime.now(),
    );

    await _hiveService.put(material.id, updatedMaterial);

    if (await _networkInfo.isConnected) {
      try {
        final allMaterials = await _hiveService.getAll();
        // Format UUIDs for Google Sheets
        final values = allMaterials.map((m) {
          final sheetMaterial = m.copyWith(
            id: _formatUuidForSheets(m.id),
          );
          return sheetMaterial.toJson().values.toList();
        }).toList();
        await _sheetsService.updateSheetData('inventory_sheet!A:F', values);
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync material with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> deleteMaterial(String id) async {
    await _hiveService.delete(id);

    if (await _networkInfo.isConnected) {
      try {
        final allMaterials = await _hiveService.getAll();
        // Format UUIDs for Google Sheets
        final values = allMaterials.map((m) {
          final sheetMaterial = m.copyWith(
            id: _formatUuidForSheets(m.id),
          );
          return sheetMaterial.toJson().values.toList();
        }).toList();
        await _sheetsService.updateSheetData('inventory_sheet!A:F', values);
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync material with Google Sheets',
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
      final sheetData = await _sheetsService.getSheetData('inventory_sheet!A:F');
      final materials = sheetData.map((row) {
        // Parse the formatted UUID back to original format
        final originalUuid = _parseUuidFromSheets(row[0]);
        return MaterialModel.fromJson({
          'id': originalUuid,
          'name': row[1],
          'currentQuantity': double.parse(row[2]),
          'thresholdQuantity': double.parse(row[3]),
          'unit': row[4],
          'lastUpdated': row[5],
        });
      }).toList();

      await _hiveService.clear();
      for (final material in materials) {
        await _hiveService.add(material);
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to sync with Google Sheets',
        code: e.toString(),
      );
    }
  }

  @override
  Future<List<MaterialModel>> getMaterialsBelowThreshold() async {
    final materials = await _hiveService.getAll();
    return materials.where((material) {
      return material.currentQuantity < material.thresholdQuantity;
    }).toList();
  }

  @override
  Stream<List<MaterialModel>> watchMaterials() {
    return _hiveService.watchAll();
  }
} 