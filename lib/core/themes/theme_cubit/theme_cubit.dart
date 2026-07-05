import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// this cubit does`nt need states classes
// because it`s dependence on ThemeMode not states

///   Without Shared preferences

// class ThemeCubit extends Cubit<ThemeMode> {
//   ThemeCubit() : super(ThemeMode.system);
//   void updateTheme(ThemeMode newMode) {
//     emit(newMode);
//   }
// }

///  Usage Shared preferences to save the theme mode

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme';

  ThemeCubit() : super(ThemeMode.system) {
    loadSavedTheme();
  }

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey);

    if (theme != null) {
      emit(
        ThemeMode.values.firstWhere(
          (e) => e.name == theme,
          orElse: () => ThemeMode.system,
        ),
      );
    }
  }

  Future<void> updateTheme(ThemeMode newMode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeKey, newMode.name);

    emit(newMode);
  }
}

/// Usage Example:
//               onPressed: () {
//                 if (context.isDarkMode) {
//                   context.read<ThemeCubit>().updateTheme(ThemeMode.light);
//                 } else {
//                   context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
//                 }
//               },
