import 'package:adhan_dart/adhan_dart.dart';
import 'package:muslim_notify/features/notification/data/models/prayer_times_model.dart';
import 'package:muslim_notify/features/notification/data/services/adhan_services/location_service.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerTimesService {
  /// Calculation Parameters
  static CalculationParameters _getCalculationParameters() {
    return CalculationMethodParameters.egyptian();
  }

  /// Convert Adhan UTC time to application local timezone
  static tz.TZDateTime _toLocalTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  static Future<PrayerTimesModel> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    final coordinates = Coordinates(latitude, longitude);

    final params = _getCalculationParameters();

    final prayerTimes = PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: params,
      precision: true,
    );

    final locationName = await LocationService.getLocationNameCached(
      latitude,
      longitude,
    );

    return PrayerTimesModel(
      date: _toLocalTime(prayerTimes.date),

      fajr: _toLocalTime(prayerTimes.fajr),

      sunrise: _toLocalTime(prayerTimes.sunrise),

      dhuhr: _toLocalTime(prayerTimes.dhuhr),

      asr: _toLocalTime(prayerTimes.asr),

      maghrib: _toLocalTime(prayerTimes.maghrib),

      isha: _toLocalTime(prayerTimes.isha),

      latitude: latitude,

      longitude: longitude,

      locationName: locationName,
    );
  }
}
