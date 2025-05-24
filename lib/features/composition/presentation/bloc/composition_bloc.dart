import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:raw_material_management/features/composition/data/models/composition_model.dart';
import 'package:raw_material_management/features/composition/domain/repositories/composition_repository.dart';

// Events
abstract class CompositionEvent extends Equatable {
  const CompositionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCompositions extends CompositionEvent {}

class AddComposition extends CompositionEvent {
  final CompositionModel composition;

  const AddComposition(this.composition);

  @override
  List<Object?> get props => [composition];
}

class UpdateComposition extends CompositionEvent {
  final CompositionModel composition;

  const UpdateComposition(this.composition);

  @override
  List<Object?> get props => [composition];
}

class DeleteComposition extends CompositionEvent {
  final String id;

  const DeleteComposition(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncCompositions extends CompositionEvent {}

// States
abstract class CompositionState extends Equatable {
  const CompositionState();

  @override
  List<Object?> get props => [];
}

class CompositionInitial extends CompositionState {}

class CompositionLoading extends CompositionState {}

class CompositionLoaded extends CompositionState {
  final List<CompositionModel> compositions;

  const CompositionLoaded(this.compositions);

  @override
  List<Object?> get props => [compositions];
}

class CompositionError extends CompositionState {
  final String message;

  const CompositionError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CompositionBloc extends Bloc<CompositionEvent, CompositionState> {
  final CompositionRepository _repository;

  CompositionBloc(this._repository) : super(CompositionInitial()) {
    on<LoadCompositions>(_onLoadCompositions);
    on<AddComposition>(_onAddComposition);
    on<UpdateComposition>(_onUpdateComposition);
    on<DeleteComposition>(_onDeleteComposition);
    on<SyncCompositions>(_onSyncCompositions);
  }

  Future<void> _onLoadCompositions(
    LoadCompositions event,
    Emitter<CompositionState> emit,
  ) async {
    emit(CompositionLoading());
    try {
      final compositions = await _repository.getAllCompositions();
      emit(CompositionLoaded(compositions));
    } catch (e) {
      emit(CompositionError(e.toString()));
    }
  }

  Future<void> _onAddComposition(
    AddComposition event,
    Emitter<CompositionState> emit,
  ) async {
    try {
      await _repository.addComposition(event.composition);
      final compositions = await _repository.getAllCompositions();
      emit(CompositionLoaded(compositions));
    } catch (e) {
      emit(CompositionError(e.toString()));
    }
  }

  Future<void> _onUpdateComposition(
    UpdateComposition event,
    Emitter<CompositionState> emit,
  ) async {
    try {
      await _repository.updateComposition(event.composition);
      final compositions = await _repository.getAllCompositions();
      emit(CompositionLoaded(compositions));
    } catch (e) {
      emit(CompositionError(e.toString()));
    }
  }

  Future<void> _onDeleteComposition(
    DeleteComposition event,
    Emitter<CompositionState> emit,
  ) async {
    try {
      await _repository.deleteComposition(event.id);
      final compositions = await _repository.getAllCompositions();
      emit(CompositionLoaded(compositions));
    } catch (e) {
      emit(CompositionError(e.toString()));
    }
  }

  Future<void> _onSyncCompositions(
    SyncCompositions event,
    Emitter<CompositionState> emit,
  ) async {
    try {
      await _repository.syncWithGoogleSheets();
      final compositions = await _repository.getAllCompositions();
      emit(CompositionLoaded(compositions));
    } catch (e) {
      emit(CompositionError(e.toString()));
    }
  }
} 