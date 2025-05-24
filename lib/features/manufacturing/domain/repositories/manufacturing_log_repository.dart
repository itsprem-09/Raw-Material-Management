import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';

abstract class ManufacturingLogRepository {
  Future<List<ManufacturingLogModel>> getAllLogs();
  Future<ManufacturingLogModel?> getLogById(String id);
  Future<void> addLog(ManufacturingLogModel log);
  Future<void> updateLog(ManufacturingLogModel log);
  Future<void> deleteLog(String id);
  Future<void> syncWithGoogleSheets();
  Stream<List<ManufacturingLogModel>> watchLogs();
  Future<List<ManufacturingLogModel>> getLogsByDateRange(DateTime start, DateTime end);
} 