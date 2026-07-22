import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/adhan_services/prayer_service.dart';
import 'prayer_times_state.dart';

class PrayerTimesCubit extends Cubit<PrayerTimesState> {
  PrayerTimesCubit() : super(const PrayerTimesInitial());

  static const int _maxRetries = 3;

  Future<void> getTodayPrayerTimes() async {
    emit(const PrayerTimesLoading());

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        log(
          '🕌 Getting today prayer times... '
          'Attempt $attempt/$_maxRetries',
        );

        final prayerTimes = await PrayerService.getTodayPrayerTimes();

        log('✅ Prayer times loaded successfully');

        emit(PrayerTimesLoaded(prayerTimes));

        return;
      } catch (e, s) {
        log('❌ Attempt $attempt failed: $e');
        log('$s');

        if (attempt < _maxRetries) {
          log('🔄 Retrying in 1 second...');

          await Future.delayed(const Duration(seconds: 1));
        } else {
          log('❌ All $_maxRetries attempts failed');

          emit(PrayerTimesError(e.toString()));
        }
      }
    }
  }
}
