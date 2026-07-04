import 'package:flutter/material.dart';

import '../../utils/app_functions.dart';
import '../app_colors.dart';
import '../app_fonts.dart';
import '../app_text_styles.dart';

ThemeData getLightTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.grey_0,
    brightness: Brightness.light,
    fontFamily: isArabic() ? AppFonts.cairo : AppFonts.manrope,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary_300,
      brightness: Brightness.light,
    ),
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.grey_900,
      displayColor: AppColors.grey_900,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary_300,
        foregroundColor: AppColors.grey_0,
        disabledBackgroundColor: AppColors.grey_100,
        disabledForegroundColor: AppColors.grey_0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppTextStyles.mSemiBold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.grey_100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.grey_100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary_200),
      ),
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return AppColors.primary_0;
        }
        return AppColors.grey_0;
      }),
      filled: true,
      hintStyle: AppTextStyles.mRegular.copyWith(color: AppColors.grey_400),
    ),
  );
}
