import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Events
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class LoadTheme extends ThemeEvent {}

// States
abstract class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(ThemeMode.system);
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded(ThemeMode themeMode) : super(themeMode);
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;
  static const String _themeKey = 'theme_mode';

  ThemeBloc(this.prefs) : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final themeModeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    emit(ThemeLoaded(ThemeMode.values[themeModeIndex]));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ThemeState> emit) {
    final currentMode = state.themeMode;
    ThemeMode newMode;

    switch (currentMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }

    prefs.setInt(_themeKey, newMode.index);
    emit(ThemeLoaded(newMode));
  }
} 