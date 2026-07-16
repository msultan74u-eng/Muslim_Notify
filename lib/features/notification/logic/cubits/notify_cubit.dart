import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/enum/notification_type.dart';
import '../../data/services/notify_manager.dart';

part 'notify_state.dart';

class NotifyCubit extends HydratedCubit<NotifyState> {
  NotifyCubit() : super(NotifyState.initial());

  final NotifyManager _notifyManager = NotifyManager();

  /// * initial state of notify

  Future<void> initializeNotifications() async {
    log("🚀 initializeNotifications CALLED");

    // Notifications that do not depend on location
    try {
      await _updateProphetSalawatNotification(state.salawatEnabled);
    } catch (e, s) {
      log("❌ Prophet Salawat Error: $e");
      log("$s");
    }

    // Notifications based on prayer times
    try {
      await refreshLocationBasedNotifications();
    } catch (e, s) {
      log("❌ Location notifications error: $e");
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

  /// * Toggle methode of notify
  // 1- Prophet Salawat notification
  Future<void> toggleProphetSalawat(bool enabled) async {
    emit(state.copyWith(salawatEnabled: enabled));
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

  Future<void> refreshNotificationTimes() async {
    log('🔄 Refreshing notification times...');

    if (state.azkarSabahEnabled) {
      await _updateAzkarSabahNotification(true);
    }

    if (state.azkarAlmasaaEnabled) {
      await _updateAzkarAlmasaaNotification(true);
    }

    if (state.azkarAlnawmEnabled) {
      await _updateAzkarAlnawmNotification(true);
    }

    if (state.nightPrayerEnabled) {
      await _updateNightPrayerNotification(true);
    }
  }

  Future<bool> refreshLocationBasedNotifications() async {
    log('🔄 Refreshing location-based notifications...');

    try {
      if (state.azkarSabahEnabled) {
        await _updateAzkarSabahNotification(true);
      }

      if (state.azkarAlmasaaEnabled) {
        await _updateAzkarAlmasaaNotification(true);
      }

      if (state.azkarAlnawmEnabled) {
        await _updateAzkarAlnawmNotification(true);
      }

      if (state.nightPrayerEnabled) {
        await _updateNightPrayerNotification(true);
      }

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
