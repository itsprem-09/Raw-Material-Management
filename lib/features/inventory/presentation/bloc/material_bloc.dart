import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:raw_material_management/features/inventory/data/models/material_model.dart';
import 'package:raw_material_management/features/inventory/domain/repositories/material_repository.dart';

// Events
abstract class MaterialEvent extends Equatable {
  const MaterialEvent();

  @override
  List<Object?> get props => [];
}

class LoadMaterials extends MaterialEvent {}

class AddMaterial extends MaterialEvent {
  final MaterialModel material;

  const AddMaterial(this.material);

  @override
  List<Object?> get props => [material];
}

class UpdateMaterial extends MaterialEvent {
  final MaterialModel material;

  const UpdateMaterial(this.material);

  @override
  List<Object?> get props => [material];
}

class DeleteMaterial extends MaterialEvent {
  final String id;

  const DeleteMaterial(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncMaterials extends MaterialEvent {}

// States
abstract class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object?> get props => [];
}

class MaterialInitial extends MaterialState {}

class MaterialLoading extends MaterialState {}

class MaterialLoaded extends MaterialState {
  final List<MaterialModel> materials;

  const MaterialLoaded(this.materials);

  @override
  List<Object?> get props => [materials];
}

class MaterialError extends MaterialState {
  final String message;

  const MaterialError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final MaterialRepository _repository;

  MaterialBloc(this._repository) : super(MaterialInitial()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<AddMaterial>(_onAddMaterial);
    on<UpdateMaterial>(_onUpdateMaterial);
    on<DeleteMaterial>(_onDeleteMaterial);
    on<SyncMaterials>(_onSyncMaterials);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    emit(MaterialLoading());
    try {
      final materials = await _repository.getAllMaterials();
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }

  Future<void> _onAddMaterial(
    AddMaterial event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      await _repository.addMaterial(event.material);
      final materials = await _repository.getAllMaterials();
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }

  Future<void> _onUpdateMaterial(
    UpdateMaterial event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      await _repository.updateMaterial(event.material);
      final materials = await _repository.getAllMaterials();
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }

  Future<void> _onDeleteMaterial(
    DeleteMaterial event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      await _repository.deleteMaterial(event.id);
      final materials = await _repository.getAllMaterials();
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }

  Future<void> _onSyncMaterials(
    SyncMaterials event,
    Emitter<MaterialState> emit,
  ) async {
    try {
      await _repository.syncWithGoogleSheets();
      final materials = await _repository.getAllMaterials();
      emit(MaterialLoaded(materials));
    } catch (e) {
      emit(MaterialError(e.toString()));
    }
  }
} 