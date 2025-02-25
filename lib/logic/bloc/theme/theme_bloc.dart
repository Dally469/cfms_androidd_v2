import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ToggleTheme extends ThemeEvent {}

class SetTheme extends ThemeEvent {
  final bool isDark;

  const SetTheme(this.isDark);

  @override
  List<Object> get props => [isDark];
}

// States
class ThemeState extends Equatable {
  final bool isDark;
  final ThemeData themeData;

  const ThemeState({
    required this.isDark,
    required this.themeData,
  });

  factory ThemeState.initial() {
    return ThemeState(
      isDark: false,
      themeData: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  ThemeState copyWith({
    bool? isDark,
    ThemeData? themeData,
  }) {
    return ThemeState(
      isDark: isDark ?? this.isDark,
      themeData: themeData ?? this.themeData,
    );
  }

  @override
  List<Object> get props => [isDark, themeData];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    on<ToggleTheme>(_onToggleTheme);
    on<SetTheme>(_onSetTheme);
  }

  void _onToggleTheme(
    ToggleTheme event,
    Emitter<ThemeState> emit,
  ) {
    final isDark = !state.isDark;
    emit(state.copyWith(
      isDark: isDark,
      themeData: _getThemeData(isDark),
    ));
  }

  void _onSetTheme(
    SetTheme event,
    Emitter<ThemeState> emit,
  ) {
    emit(state.copyWith(
      isDark: event.isDark,
      themeData: _getThemeData(event.isDark),
    ));
  }

  ThemeData _getThemeData(bool isDark) {
    return isDark
        ? ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          )
        : ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
          );
  }
}
