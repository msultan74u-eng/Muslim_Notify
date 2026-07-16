import '../enum/prayer_type.dart';

abstract final class NotificationIds {
  /// Salawat Notifications
  static const int prophetPrayer = 1;

  /// Azkar Notifications
  static const int azkarSabah = 2;
  static const int azkarAlmasaa = 3;
  static const int azkarAlnawm = 4;

  /// Night Prayer
  static const int nightPrayer = 5;

  /// Prayer Reminder Notifications
  static int prayerReminderId(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => 10,
      PrayerType.dhuhr => 11,
      PrayerType.asr => 12,
      PrayerType.maghrib => 13,
      PrayerType.isha => 14,
    };
  }

  /// Adhan Notifications
  static int prayerAdhanId(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => 20,
      PrayerType.dhuhr => 21,
      PrayerType.asr => 22,
      PrayerType.maghrib => 23,
      PrayerType.isha => 24,
    };
  }
}
