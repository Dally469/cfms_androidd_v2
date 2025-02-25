import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/update_repository.dart';

// Events
abstract class UpdateEvent extends Equatable {
  const UpdateEvent();

  @override
  List<Object> get props => [];
}

class CheckForUpdate extends UpdateEvent {}

class PerformUpdate extends UpdateEvent {}

// States
abstract class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object> get props => [];
}

class UpdateInitial extends UpdateState {
  final String currentVersion;
  final String buildNumber;

  const UpdateInitial({
    required this.currentVersion,
    required this.buildNumber,
  });

  @override
  List<Object> get props => [currentVersion, buildNumber];
}

class UpdateLoading extends UpdateState {}

class UpdateAvailable extends UpdateState {
  final String currentVersion;
  final String newVersion;

  const UpdateAvailable({
    required this.currentVersion,
    required this.newVersion,
  });

  @override
  List<Object> get props => [currentVersion, newVersion];
}

class UpdateNotAvailable extends UpdateState {
  final String currentVersion;

  const UpdateNotAvailable(this.currentVersion);

  @override
  List<Object> get props => [currentVersion];
}

class UpdateInProgress extends UpdateState {}

class UpdateSuccess extends UpdateState {}

class UpdateFailure extends UpdateState {
  final String error;

  const UpdateFailure(this.error);

  @override
  List<Object> get props => [error];
}

// BLoC
class UpdateBloc extends Bloc<UpdateEvent, UpdateState> {
  final UpdateRepository updateRepository;

  UpdateBloc({
    required this.updateRepository,
    required String currentVersion,
    required String buildNumber,
  }) : super(UpdateInitial(
            currentVersion: currentVersion, buildNumber: buildNumber)) {
    on<CheckForUpdate>(_onCheckForUpdate);
    on<PerformUpdate>(_onPerformUpdate);
  }

  Future<void> _onCheckForUpdate(
    CheckForUpdate event,
    Emitter<UpdateState> emit,
  ) async {
    emit(UpdateLoading());
    try {
      final updateInfo = await updateRepository.checkForUpdate();
      if (updateInfo.isAvailable) {
        emit(UpdateAvailable(
          currentVersion: updateInfo.currentVersion,
          newVersion: updateInfo.newVersion ?? 'Unknown',
        ));
      } else {
        emit(UpdateNotAvailable(updateInfo.currentVersion));
      }
    } catch (e) {
      emit(UpdateFailure(e.toString()));
    }
  }

  Future<void> _onPerformUpdate(
    PerformUpdate event,
    Emitter<UpdateState> emit,
  ) async {
    emit(UpdateInProgress());
    try {
      final success = await updateRepository.performUpdate();
      if (success) {
        emit(UpdateSuccess());
      } else {
        emit(const UpdateFailure('Update failed'));
      }
    } catch (e) {
      emit(UpdateFailure(e.toString()));
    }
  }
}
