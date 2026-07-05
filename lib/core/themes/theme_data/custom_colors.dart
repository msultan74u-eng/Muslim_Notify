import 'package:flutter/material.dart';
import 'package:muslim_notify/core/themes/app_colors.dart';

class CustomColors {
  CustomColors._({required this.secondaryColor});

  final Color secondaryColor;

  factory CustomColors._light() {
    return CustomColors._(secondaryColor: AppColors.primary_300);
  }
  factory CustomColors._dark() {
    return CustomColors._(secondaryColor: AppColors.error_300);
  }
}

extension CustomColorsEx on ThemeData {
  CustomColors get customColors {
    if (brightness == Brightness.dark) {
      return CustomColors._dark();
    } else {
      return CustomColors._light();
    }
  }
}
