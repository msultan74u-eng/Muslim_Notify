import '../../data/models/prayer_times_model.dart';

sealed class PrayerTimesState {
  const PrayerTimesState();
}

class PrayerTimesInitial extends PrayerTimesState {
  const PrayerTimesInitial();
}

class PrayerTimesLoading extends PrayerTimesState {
  const PrayerTimesLoading();
}

class PrayerTimesLoaded extends PrayerTimesState {
  final PrayerTimesModel prayerTimes;

  const PrayerTimesLoaded(this.prayerTimes);
}

class PrayerTimesError extends PrayerTimesState {
  final String message;

  const PrayerTimesError(this.message);
}
