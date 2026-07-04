import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  const AppShadows._();
  static BoxShadow shadow_1 = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 2,
    spreadRadius: 0,
    color: AppColors.colorShadow_1.withValues(alpha: 0.5),
  );
}
