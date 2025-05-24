import 'package:raw_material_management/features/inventory/data/models/material_model.dart';

abstract class MaterialRepository {
  Future<List<MaterialModel>> getAllMaterials();
  Future<MaterialModel?> getMaterialById(String id);
  Future<void> addMaterial(MaterialModel material);
  Future<void> updateMaterial(MaterialModel material);
  Future<void> deleteMaterial(String id);
  Future<void> syncWithGoogleSheets();
  Future<List<MaterialModel>> getMaterialsBelowThreshold();
  Stream<List<MaterialModel>> watchMaterials();
} 