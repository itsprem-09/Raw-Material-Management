import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:raw_material_management/features/manufacturing/data/models/manufacturing_log_model.dart';
import 'package:raw_material_management/features/manufacturing/domain/repositories/manufacturing_log_repository.dart';

// Events
abstract class ManufacturingLogEvent extends Equatable {
  const ManufacturingLogEvent();

  @override
  List<Object?> get props => [];
}

class LoadManufacturingLogs extends ManufacturingLogEvent {}

class AddManufacturingLog extends ManufacturingLogEvent {
  final ManufacturingLogModel log;

  const AddManufacturingLog(this.log);

  @override
  List<Object?> get props => [log];
}

class UpdateManufacturingLog extends ManufacturingLogEvent {
  final ManufacturingLogModel log;

  const UpdateManufacturingLog(this.log);

  @override
  List<Object?> get props => [log];
}

class DeleteManufacturingLog extends ManufacturingLogEvent {
  final String id;

  const DeleteManufacturingLog(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncManufacturingLogs extends ManufacturingLogEvent {}

class LoadLogsByDateRange extends ManufacturingLogEvent {
  final DateTime start;
  final DateTime end;

  const LoadLogsByDateRange({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];
}

// States
abstract class ManufacturingLogState extends Equatable {
  const ManufacturingLogState();

  @override
  List<Object?> get props => [];
}

class ManufacturingLogInitial extends ManufacturingLogState {}

class ManufacturingLogLoading extends ManufacturingLogState {}

class ManufacturingLogLoaded extends ManufacturingLogState {
  final List<ManufacturingLogModel> logs;

  const ManufacturingLogLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class ManufacturingLogError extends ManufacturingLogState {
  final String message;

  const ManufacturingLogError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ManufacturingLogBloc
    extends Bloc<ManufacturingLogEvent, ManufacturingLogState> {
  final ManufacturingLogRepository _repository;

  ManufacturingLogBloc(this._repository) : super(ManufacturingLogInitial()) {
    on<LoadManufacturingLogs>(_onLoadManufacturingLogs);
    on<AddManufacturingLog>(_onAddManufacturingLog);
    on<UpdateManufacturingLog>(_onUpdateManufacturingLog);
    on<DeleteManufacturingLog>(_onDeleteManufacturingLog);
    on<SyncManufacturingLogs>(_onSyncManufacturingLogs);
    on<LoadLogsByDateRange>(_onLoadLogsByDateRange);
  }

  Future<void> _onLoadManufacturingLogs(
    LoadManufacturingLogs event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    emit(ManufacturingLogLoading());
    try {
      final logs = await _repository.getAllLogs();
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }

  Future<void> _onAddManufacturingLog(
    AddManufacturingLog event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    try {
      await _repository.addLog(event.log);
      final logs = await _repository.getAllLogs();
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }

  Future<void> _onUpdateManufacturingLog(
    UpdateManufacturingLog event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    try {
      await _repository.updateLog(event.log);
      // Refetch all logs to update the UI
      final logs = await _repository.getAllLogs();
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }

  Future<void> _onDeleteManufacturingLog(
    DeleteManufacturingLog event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    try {
      await _repository.deleteLog(event.id);
      final logs = await _repository.getAllLogs();
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }

  Future<void> _onSyncManufacturingLogs(
    SyncManufacturingLogs event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    try {
      await _repository.syncWithGoogleSheets();
      final logs = await _repository.getAllLogs();
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }

  Future<void> _onLoadLogsByDateRange(
    LoadLogsByDateRange event,
    Emitter<ManufacturingLogState> emit,
  ) async {
    emit(ManufacturingLogLoading());
    try {
      final logs = await _repository.getLogsByDateRange(
        event.start,
        event.end,
      );
      emit(ManufacturingLogLoaded(logs));
    } catch (e) {
      emit(ManufacturingLogError(e.toString()));
    }
  }
} 