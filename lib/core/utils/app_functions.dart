import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// check if the current language is arabic
bool isArabic() {
  return intl.Intl.getCurrentLocale().startsWith('ar');
}

/// check if the current theme is dark
extension ContextEx on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
