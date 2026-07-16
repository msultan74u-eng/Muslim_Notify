import 'package:muslim_notify/features/notification/data/models/prayer_times_model.dart';
import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimesService {
  /// 1-  calculatePrayerTimes();

  // pathing Parameters
  static CalculationParameters _getCalculationParameters() {
    final params = CalculationMethodParameters.egyptian();
    return params;
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
    return PrayerTimesModel(
      date: prayerTimes.date,
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
