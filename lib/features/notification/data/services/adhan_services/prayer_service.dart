// Orchestrator service

import 'package:muslim_notify/features/notification/data/enum/prayer_type.dart';
import 'package:muslim_notify/features/notification/data/models/prayer_times_model.dart';
import 'package:muslim_notify/features/notification/data/services/adhan_services/location_service.dart';
import 'package:muslim_notify/features/notification/data/services/adhan_services/prayer_times_service.dart';
import 'package:muslim_notify/features/notification/data/services/timezone_service.dart';

class PrayerService {
  /// 1- Get prayer times for a specific date

  static Future<PrayerTimesModel> getPrayerTimes(DateTime date) async {
    final position = await LocationService.getLocationWithFallback();

    return PrayerTimesService.calculatePrayerTimes(
      latitude: position.latitude,
      longitude: position.longitude,
      date: date,
    );
  }

  /// 2- Get today's prayer times
  static Future<PrayerTimesModel> getTodayPrayerTimes() {
    return getPrayerTimes(TimezoneService.currentTime());
  }

  /// 3- Get next prayer
  static PrayerType getNextPrayer(
    PrayerTimesModel prayerTimes,
    DateTime currentTime,
  ) {
    final prayers = [
      (PrayerType.fajr, prayerTimes.fajr),
      (PrayerType.dhuhr, prayerTimes.dhuhr),
      (PrayerType.asr, prayerTimes.asr),
      (PrayerType.maghrib, prayerTimes.maghrib),
      (PrayerType.isha, prayerTimes.isha),
    ];

    for (final prayer in prayers) {
      if (!currentTime.isAfter(prayer.$2)) {
        return prayer.$1;
      }
    }
    return PrayerType.fajr;
  }

  /// 4- Get prayer time
  static DateTime getPrayerTime(
    PrayerTimesModel prayerTimes,

    PrayerType prayerType,
  ) {
    switch (prayerType) {
      case PrayerType.fajr:
        return prayerTimes.fajr;

      case PrayerType.dhuhr:
        return prayerTimes.dhuhr;

      case PrayerType.asr:
        return prayerTimes.asr;

      case PrayerType.maghrib:
        return prayerTimes.maghrib;

      case PrayerType.isha:
        return prayerTimes.isha;
    }
  }

  /// 5- Get remaining Time
  static Duration getRemainingTime(
    PrayerTimesModel prayerTimes,
    DateTime currentTime,
  ) {
    final nextPrayer = getNextPrayer(prayerTimes, currentTime);
    DateTime nextPrayerTime = getPrayerTime(prayerTimes, nextPrayer);
    if (nextPrayer == PrayerType.fajr &&
        currentTime.isAfter(prayerTimes.isha)) {
      nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
    }
    return nextPrayerTime.difference(currentTime);
  }

  /// 6- Get Night Duration
  static Future<Duration> getNightDuration(PrayerTimesModel prayerTimes) async {
    final maghrib = getPrayerTime(prayerTimes, PrayerType.maghrib);

    final tomorrowPrayerTimes = await _getPrayerTimesForDate(
      prayerTimes,
      prayerTimes.date.add(const Duration(days: 1)),
    );

    final tomorrowFajr = getPrayerTime(tomorrowPrayerTimes, PrayerType.fajr);

    return tomorrowFajr.difference(maghrib);
  }

  /// 7- Get middle of night
  static Future<DateTime> getMiddleOfNight(PrayerTimesModel prayerTimes) async {
    final maghrib = getPrayerTime(prayerTimes, PrayerType.maghrib);
    final nightDuration = await getNightDuration(prayerTimes);
    final halfNight = _divideDuration(nightDuration, 2);
    return maghrib.add(halfNight);
  }

  /// 8- Get last third of night
  static Future<DateTime> getLastThirdOfNight(
    PrayerTimesModel prayerTimes,
  ) async {
    final nightDuration = await getNightDuration(prayerTimes);

    final thirdNight = _divideDuration(nightDuration, 3);

    final tomorrowPrayerTimes = await _getPrayerTimesForDate(
      prayerTimes,
      prayerTimes.date.add(const Duration(days: 1)),
    );

    final tomorrowFajr = getPrayerTime(tomorrowPrayerTimes, PrayerType.fajr);

    final lastThirdStart = tomorrowFajr.subtract(thirdNight);

    return lastThirdStart;
  }

  /// 9- Get night prayer notification time
  static Future<DateTime> getNightPrayerNotificationTime(
    PrayerTimesModel prayerTimes,
  ) async {
    return await getLastThirdOfNight(prayerTimes);
  }

  /// 10- Get morning Azkar notification time
  static DateTime getMorningAzkarTime(PrayerTimesModel prayerTimes) {
    return prayerTimes.fajr.add(const Duration(hours: 1));
  }

  /// 11- Get evening Azkar notification time
  static DateTime getEveningAzkarTime(PrayerTimesModel prayerTimes) {
    return prayerTimes.asr.add(const Duration(hours: 1));
  }

  /// 12- Get sleeping Azkar notification time
  static DateTime getSleepingAzkarTime(PrayerTimesModel prayerTimes) {
    return prayerTimes.isha.add(const Duration(hours: 1));
  }

  /// Private helpers
  static Future<PrayerTimesModel> _getPrayerTimesForDate(
    PrayerTimesModel prayerTimes,
    DateTime date,
  ) {
    return PrayerTimesService.calculatePrayerTimes(
      latitude: prayerTimes.latitude,
      longitude: prayerTimes.longitude,
      date: date,
    );
  }

  static Duration _divideDuration(Duration duration, int divisor) {
    return Duration(milliseconds: duration.inMilliseconds ~/ divisor);
  }

  static List<(PrayerType, DateTime)> getAllPrayers(
    PrayerTimesModel prayerTimes,
  ) {
    return [
      (PrayerType.fajr, prayerTimes.fajr),
      (PrayerType.dhuhr, prayerTimes.dhuhr),
      (PrayerType.asr, prayerTimes.asr),
      (PrayerType.maghrib, prayerTimes.maghrib),
      (PrayerType.isha, prayerTimes.isha),
    ];
  }
}
