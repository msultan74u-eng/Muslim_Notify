import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_fonts.dart';
import '../app_text_styles.dart';

ThemeData getDarkTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.grey_900,
    brightness: Brightness.dark,
    fontFamily: AppFonts.manrope,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary_300,
      brightness: Brightness.dark,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.grey_0,
      displayColor: AppColors.grey_0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary_300,
        foregroundColor: AppColors.grey_0,
        disabledBackgroundColor: AppColors.grey_800,
        disabledForegroundColor: AppColors.grey_400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.mSemiBold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey_100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.grey_100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary_200),
      ),
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return AppColors.darkFillColor;
        }
        return AppColors.grey_800;
      }),
      filled: true,
      hintStyle: AppTextStyles.mRegular.copyWith(color: AppColors.grey_400),
    ),
  );
}
