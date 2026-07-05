import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

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

// class ThemeCubit extends Cubit<ThemeMode> {
//   static const String _themeKey = 'app_theme';
//
//   ThemeCubit() : super(ThemeMode.system) {
//     loadSavedTheme();
//   }
//
//   Future<void> loadSavedTheme() async {
//     final prefs = await SharedPreferences.getInstance();
//     final theme = prefs.getString(_themeKey);
//
//     if (theme != null) {
//       emit(
//         ThemeMode.values.firstWhere(
//           (e) => e.name == theme,
//           orElse: () => ThemeMode.system,
//         ),
//       );
//     }
//   }
//
//   Future<void> updateTheme(ThemeMode newMode) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.setString(_themeKey, newMode.name);
//
//     emit(newMode);
//   }
// }

///   Usage with Hydrated Bloc
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  final String _themeKey = 'app_theme';

  void updateTheme(ThemeMode newMode) {
    emit(newMode);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final saveMode = json[_themeKey];
    if (saveMode == 'light') {
      return ThemeMode.light;
    } else if (saveMode == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode newMode) {
    if (newMode == ThemeMode.light) {
      return {_themeKey: 'light'};
    } else if (newMode == ThemeMode.dark) {
      return {_themeKey: 'dark'};
    } else {
      return {_themeKey: 'system'};
    }
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
