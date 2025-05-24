import 'package:raw_material_management/features/composition/data/models/composition_model.dart';

abstract class CompositionRepository {
  Future<List<CompositionModel>> getAllCompositions();
  Future<CompositionModel?> getCompositionById(String id);
  Future<void> addComposition(CompositionModel composition);
  Future<void> updateComposition(CompositionModel composition);
  Future<void> deleteComposition(String id);
  Future<void> syncWithGoogleSheets();
  Stream<List<CompositionModel>> watchCompositions();
} 