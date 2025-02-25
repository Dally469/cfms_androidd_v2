import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/language_repository.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final String languageCode;

  const ChangeLanguage(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

class LoadLanguage extends LanguageEvent {}

// States
abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String languageCode;

  const LanguageLoaded(this.languageCode);

  @override
  List<Object> get props => [languageCode];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository languageRepository;
  final String initialLanguage;

  LanguageBloc(
      {required this.languageRepository, required this.initialLanguage})
      : super(LanguageLoaded(initialLanguage)) {
    on<ChangeLanguage>(_onChangeLanguage);
    on<LoadLanguage>(_onLoadLanguage);
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    await languageRepository.setLanguage(event.languageCode);
    emit(LanguageLoaded(event.languageCode));
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoading());
    final languageCode =
        await languageRepository.getLanguage() ?? initialLanguage;
    emit(LanguageLoaded(languageCode));
  }
}
