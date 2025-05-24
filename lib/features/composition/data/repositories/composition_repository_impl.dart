import 'package:raw_material_management/core/error/failures.dart';
import 'package:raw_material_management/core/network/network_info.dart';
import 'package:raw_material_management/core/services/google_sheets_service.dart';
import 'package:raw_material_management/core/services/hive_service.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/composition/domain/repositories/composition_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class CompositionRepositoryImpl implements CompositionRepository {
  final HiveService<CompositionModel> _hiveService;
  final GoogleSheetsService _sheetsService;
  final NetworkInfo _networkInfo;

  CompositionRepositoryImpl({
    required HiveService<CompositionModel> hiveService,
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
  String _formatMaterialsForSheets(List<MaterialComposition> materials) {
    return materials.map((m) => 
      '${m.materialName} (${m.quantity} ${m.unit})'
    ).join(' | ');
  }

  // Helper method to parse materials from Google Sheets format
  List<MaterialComposition> _parseMaterialsFromSheets(String formattedMaterials, Map<String, MaterialComposition> materialMap) {
    final materialStrings = formattedMaterials.split(' | ');
    return materialStrings.map((str) {
      // Extract material name, quantity, and unit from the string
      // Format: "Material Name (quantity unit)"
      final match = RegExp(r'(.+?)\s*\((\d+\.?\d*)\s*(\w+)\)').firstMatch(str);
      if (match != null) {
        final materialName = match.group(1)?.trim() ?? '';
        final quantity = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        final unit = match.group(3)?.trim() ?? '';
        
        // Find the material ID from the material map
        final material = materialMap.values.firstWhere(
          (m) => m.materialName == materialName && m.unit == unit,
          orElse: () => MaterialComposition(
            materialId: '',
            materialName: materialName,
            quantity: quantity,
            unit: unit,
          ),
        );

        return MaterialComposition(
          materialId: material.materialId,
          materialName: materialName,
          quantity: quantity,
          unit: unit,
        );
      }
      return MaterialComposition(
        materialId: '',
        materialName: str,
        quantity: 0,
        unit: '',
      );
    }).toList();
  }

  @override
  Future<List<CompositionModel>> getAllCompositions() async {
    return _hiveService.getAll();
  }

  @override
  Future<CompositionModel?> getCompositionById(String id) async {
    return _hiveService.get(id);
  }

  @override
  Future<void> addComposition(CompositionModel composition) async {
    final newComposition = composition.copyWith(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _hiveService.add(newComposition);

    if (await _networkInfo.isConnected) {
      try {
        // Create a copy of the composition with formatted UUID and materials
        final sheetComposition = newComposition.copyWith(
          id: _formatUuidForSheets(newComposition.id),
        );
        
        // Convert the composition to a format suitable for Google Sheets
        final values = [
          sheetComposition.id,
          sheetComposition.productName,
          _formatMaterialsForSheets(sheetComposition.materials),
          sheetComposition.createdAt.toIso8601String(),
          sheetComposition.updatedAt.toIso8601String(),
        ];

        await _sheetsService.appendSheetData(
          'composition_sheet!A1:E1',
          [values],
        );
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync composition with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> updateComposition(CompositionModel composition) async {
    final updatedComposition = composition.copyWith(
      updatedAt: DateTime.now(),
    );

    await _hiveService.put(composition.id, updatedComposition);

    if (await _networkInfo.isConnected) {
      try {
        final allCompositions = await _hiveService.getAll();
        // Format compositions for Google Sheets
        final values = allCompositions.map((c) {
          final sheetComposition = c.copyWith(
            id: _formatUuidForSheets(c.id),
          );
          return [
            sheetComposition.id,
            sheetComposition.productName,
            _formatMaterialsForSheets(sheetComposition.materials),
            sheetComposition.createdAt.toIso8601String(),
            sheetComposition.updatedAt.toIso8601String(),
          ];
        }).toList();
        await _sheetsService.updateSheetData('composition_sheet!A:E', values);
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync composition with Google Sheets',
          code: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> deleteComposition(String id) async {
    await _hiveService.delete(id);

    if (await _networkInfo.isConnected) {
      try {
        final allCompositions = await _hiveService.getAll();
        // Format compositions for Google Sheets
        final values = allCompositions.map((c) {
          final sheetComposition = c.copyWith(
            id: _formatUuidForSheets(c.id),
          );
          return [
            sheetComposition.id,
            sheetComposition.productName,
            _formatMaterialsForSheets(sheetComposition.materials),
            sheetComposition.createdAt.toIso8601String(),
            sheetComposition.updatedAt.toIso8601String(),
          ];
        }).toList();
        await _sheetsService.updateSheetData('composition_sheet!A:E', values);
      } catch (e) {
        throw ServerFailure(
          message: 'Failed to sync composition with Google Sheets',
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
      final sheetData = await _sheetsService.getSheetData('composition_sheet!A:E');
      
      // Create a map of all materials for easy lookup
      final allMaterials = await _hiveService.getAll();
      final materialMap = <String, MaterialComposition>{};
      for (final composition in allMaterials) {
        for (final material in composition.materials) {
          materialMap[material.materialName] = material;
        }
      }

      final compositions = sheetData.map((row) {
        // Parse the formatted UUID back to original format
        final originalUuid = _parseUuidFromSheets(row[0]);
        // Parse the materials string back to a list
        final materials = _parseMaterialsFromSheets(row[2], materialMap);

        return CompositionModel(
          id: originalUuid,
          productName: row[1],
          materials: materials,
          createdAt: DateTime.parse(row[3]),
          updatedAt: DateTime.parse(row[4]),
        );
      }).toList();

      await _hiveService.clear();
      for (final composition in compositions) {
        await _hiveService.add(composition);
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to sync with Google Sheets',
        code: e.toString(),
      );
    }
  }

  @override
  Stream<List<CompositionModel>> watchCompositions() {
    return _hiveService.watchAll();
  }
} 