import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/enum/notification_type.dart';
import '../../data/enum/prayer_type.dart';
import '../../data/services/notify_manager.dart';

part 'notify_state.dart';

class NotifyCubit extends HydratedCubit<NotifyState> {
  NotifyCubit() : super(NotifyState.initial());

  final NotifyManager _notifyManager = NotifyManager();

  /// * initial state of notify

  Future<void> initializeNotifications() async {
    log("🚀 initializeNotifications CALLED");

    await initializeProphetSalawatOnly();

    try {
      await refreshLocationBasedNotifications();
    } catch (e, s) {
      log("❌ Location notifications error: $e");
      log("$s");
    }
  }

  Future<void> initializeProphetSalawatOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('salawat_enabled', state.salawatEnabled);

    try {
      await _updateProphetSalawatNotification(state.salawatEnabled);
    } catch (e, s) {
      log("❌ Prophet Salawat Error: $e");
      log("$s");
    }
  }

  /// * Update methode of notify
  // 1- Prophet Salawat notification
  Future<void> _updateProphetSalawatNotification(bool enabled) async {
    if (enabled) {
      await _notifyManager.enableNotifications(
        NotificationType.prophetSalawat,
        salawatIntervalIndex: state.salawatIntervalIndex,
        fridayBoost: state.fridayBoost,
      );
    } else {
      await _notifyManager.disableNotifications(
        NotificationType.prophetSalawat,
      );
    }
  }

  // 2- Azkar Sabah notification
  Future<void> _updateAzkarSabahNotification(bool enabled) async {
    if (enabled) {
      final scheduledTime = await _notifyManager.enableNotifications(
        NotificationType.azkarSabah,
      );

      emit(state.copyWith(azkarSabahTime: scheduledTime));
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarSabah);

      emit(state.copyWith(azkarSabahTime: null));
    }
  }

  // 3- Azkar Almasaa notification
  Future<void> _updateAzkarAlmasaaNotification(bool enabled) async {
    if (enabled) {
      final scheduledTime = await _notifyManager.enableNotifications(
        NotificationType.azkarAlmasaa,
      );

      emit(state.copyWith(azkarAlmasaaTime: scheduledTime));
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarAlmasaa);

      emit(state.copyWith(azkarAlmasaaTime: null));
    }
  }

  // 4- Azkar Alnawm notification
  Future<void> _updateAzkarAlnawmNotification(bool enabled) async {
    if (enabled) {
      final scheduledTime = await _notifyManager.enableNotifications(
        NotificationType.azkarAlnawm,
      );

      emit(state.copyWith(azkarAlnawmTime: scheduledTime));
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarAlnawm);

      emit(state.copyWith(azkarAlnawmTime: null));
    }
  }

  // 5- Night Prayer notification
  Future<void> _updateNightPrayerNotification(bool enabled) async {
    if (enabled) {
      final scheduledTime = await _notifyManager.enableNotifications(
        NotificationType.nightPrayer,
      );

      emit(state.copyWith(nightPrayerTime: scheduledTime));
    } else {
      await _notifyManager.disableNotifications(NotificationType.nightPrayer);

      emit(state.copyWith(nightPrayerTime: null));
    }
  }

  // 6- Prayer Reminder notification
  Future<void> _updatePrayerReminderNotification(bool enabled) async {
    if (enabled) {
      await _notifyManager.enableNotifications(NotificationType.prayerReminder);
    } else {
      await _notifyManager.disableNotifications(
        NotificationType.prayerReminder,
      );
    }
  }

  // 7- Prayer Adhan notification
  Future<void> _updatePrayerAdhanNotification() async {
    // cancel prayer adhan notifications
    await _notifyManager.disableNotifications(NotificationType.prayerAdhan);

    // verify prayer adhan states and enable at least one prayer adhan
    final hasAnyEnabled =
        state.fajrAdhanEnabled ||
        state.dhuhrAdhanEnabled ||
        state.asrAdhanEnabled ||
        state.maghribAdhanEnabled ||
        state.ishaAdhanEnabled;

    // if no prayer adhan is enabled, return
    if (!hasAnyEnabled) {
      return;
    }

    // reschedule prayer adhan
    await _notifyManager.enableNotifications(
      NotificationType.prayerAdhan,
      fajrAdhanEnabled: state.fajrAdhanEnabled,
      dhuhrAdhanEnabled: state.dhuhrAdhanEnabled,
      asrAdhanEnabled: state.asrAdhanEnabled,
      maghribAdhanEnabled: state.maghribAdhanEnabled,
      ishaAdhanEnabled: state.ishaAdhanEnabled,
    );
  }

  /// * Toggle methode of notify
  // 1- Prophet Salawat notification
  Future<void> toggleProphetSalawat(bool enabled) async {
    emit(state.copyWith(salawatEnabled: enabled));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('salawat_enabled', enabled);
    await _updateProphetSalawatNotification(enabled);
  }

  // 2- Azkar Sabah notification
  Future<void> toggleAzkarSabah(bool enabled) async {
    emit(state.copyWith(azkarSabahEnabled: enabled));
    await _updateAzkarSabahNotification(enabled);
  }

  // 3- Azkar Almasaa notification
  Future<void> toggleAzkarAlmasaa(bool enabled) async {
    emit(state.copyWith(azkarAlmasaaEnabled: enabled));
    await _updateAzkarAlmasaaNotification(enabled);
  }

  // 4- Azkar Alnawm notification
  Future<void> toggleAzkarAlnawm(bool enabled) async {
    emit(state.copyWith(azkarAlnawmEnabled: enabled));
    await _updateAzkarAlnawmNotification(enabled);
  }

  // 5- Night Prayer notification
  Future<void> toggleNightPrayer(bool enabled) async {
    emit(state.copyWith(nightPrayerEnabled: enabled));
    await _updateNightPrayerNotification(enabled);
  }

  // 6- Prayer Reminder notification
  Future<void> togglePrayerReminder(bool enabled) async {
    emit(state.copyWith(prayerReminderEnable: enabled));

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('prayer_reminder_enabled', enabled);

    await _updatePrayerReminderNotification(enabled);
  }

  // 7- Prayer Adhan notification
  Future<void> togglePrayerAdhanByType(PrayerType prayer, bool enabled) async {
    // update  prayer state
    switch (prayer) {
      case PrayerType.fajr:
        emit(state.copyWith(fajrAdhanEnabled: enabled));
        break;

      case PrayerType.dhuhr:
        emit(state.copyWith(dhuhrAdhanEnabled: enabled));
        break;

      case PrayerType.asr:
        emit(state.copyWith(asrAdhanEnabled: enabled));
        break;

      case PrayerType.maghrib:
        emit(state.copyWith(maghribAdhanEnabled: enabled));
        break;

      case PrayerType.isha:
        emit(state.copyWith(ishaAdhanEnabled: enabled));
        break;
    }

    // save states in shared preferences
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('fajr_adhan_enabled', state.fajrAdhanEnabled);

    await prefs.setBool('dhuhr_adhan_enabled', state.dhuhrAdhanEnabled);

    await prefs.setBool('asr_adhan_enabled', state.asrAdhanEnabled);

    await prefs.setBool('maghrib_adhan_enabled', state.maghribAdhanEnabled);

    await prefs.setBool('isha_adhan_enabled', state.ishaAdhanEnabled);

    // reschedule prayer adhan
    await _updatePrayerAdhanNotification();
  }

  ///
  ///

  Future<void> changeSalawatInterval(int index) async {
    /// save index in shared preferences for work manager to create notification
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('salawat_interval_index', index);

    emit(state.copyWith(salawatIntervalIndex: index));

    if (state.salawatEnabled) {
      await _notifyManager.enableNotifications(
        NotificationType.prophetSalawat,
        salawatIntervalIndex: index,
        fridayBoost: state.fridayBoost,
      );
    }
  }

  Future<void> changeFridayBoost(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('friday_boost', value);

    emit(state.copyWith(fridayBoost: value));

    if (state.salawatEnabled) {
      await _notifyManager.enableNotifications(
        NotificationType.prophetSalawat,
        salawatIntervalIndex: state.salawatIntervalIndex,
        fridayBoost: value,
      );
    }
  }

  Future<bool> refreshLocationBasedNotifications() async {
    log('🔄 Refreshing location-based notifications...');

    try {
      final prefs = await SharedPreferences.getInstance();

      // حفظ حالة Prayer Reminder لاستخدامها في WorkManager
      await prefs.setBool(
        'prayer_reminder_enabled',
        state.prayerReminderEnable,
      );

      // save prayer adhan states in shared preferences
      await prefs.setBool('fajr_adhan_enabled', state.fajrAdhanEnabled);

      await prefs.setBool('dhuhr_adhan_enabled', state.dhuhrAdhanEnabled);

      await prefs.setBool('asr_adhan_enabled', state.asrAdhanEnabled);

      await prefs.setBool('maghrib_adhan_enabled', state.maghribAdhanEnabled);

      await prefs.setBool('isha_adhan_enabled', state.ishaAdhanEnabled);

      // 1- azkarSabah
      if (state.azkarSabahEnabled) {
        await _updateAzkarSabahNotification(true);
      }

      // 2- azkarAlmasaa
      if (state.azkarAlmasaaEnabled) {
        await _updateAzkarAlmasaaNotification(true);
      }

      // 3- azkarAlnawm
      if (state.azkarAlnawmEnabled) {
        await _updateAzkarAlnawmNotification(true);
      }

      // 4- Night Prayer
      if (state.nightPrayerEnabled) {
        await _updateNightPrayerNotification(true);
      }

      // 5- Prayer Reminder
      if (state.prayerReminderEnable) {
        await _updatePrayerReminderNotification(true);
      }

      // 6- Prayer Adhan
      await _updatePrayerAdhanNotification();

      return true;
    } catch (e, s) {
      log('❌ Location notifications error: $e');
      log('$s');

      return false;
    }
  }

  /// Hydrated
  @override
  NotifyState? fromJson(Map<String, dynamic> json) {
    return NotifyState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(NotifyState state) {
    return state.toMap();
  }
}
