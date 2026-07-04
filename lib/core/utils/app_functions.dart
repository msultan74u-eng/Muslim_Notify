import 'package:intl/intl.dart' as intl;

bool isArabic() {
  return intl.Intl.getCurrentLocale().startsWith('ar');
}
