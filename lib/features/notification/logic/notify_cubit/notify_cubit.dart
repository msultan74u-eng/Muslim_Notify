import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/enum/location_status.dart';
import '../../data/enum/notification_type.dart';
import '../../data/enum/prayer_type.dart';
import '../../data/services/adhan_services/location_service.dart';
import '../../data/services/notify_manager.dart';
import '../../data/services/timezone_service.dart';

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
    emit(state.copyWith(locationStatus: LocationStatus.loading));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        'prayer_reminder_enabled',
        state.prayerReminderEnable,
      );
      await prefs.setBool('fajr_adhan_enabled', state.fajrAdhanEnabled);
      await prefs.setBool('dhuhr_adhan_enabled', state.dhuhrAdhanEnabled);
      await prefs.setBool('asr_adhan_enabled', state.asrAdhanEnabled);
      await prefs.setBool('maghrib_adhan_enabled', state.maghribAdhanEnabled);
      await prefs.setBool('isha_adhan_enabled', state.ishaAdhanEnabled);

      // شغّل التحديثات المستقلة عن بعض بالتوازي بدل التتابع
      await Future.wait([
        if (state.azkarSabahEnabled) _updateAzkarSabahNotification(true),
        if (state.azkarAlmasaaEnabled) _updateAzkarAlmasaaNotification(true),
        if (state.azkarAlnawmEnabled) _updateAzkarAlnawmNotification(true),
        if (state.nightPrayerEnabled) _updateNightPrayerNotification(true),
        if (state.prayerReminderEnable) _updatePrayerReminderNotification(true),
      ]);

      await _updatePrayerAdhanNotification();

      emit(state.copyWith(locationStatus: LocationStatus.success));
      return true;
    } catch (e, s) {
      log('❌ Location notifications error: $e');
      log('$s');
      emit(state.copyWith(locationStatus: LocationStatus.error));
      return false;
    }
  }

  Future<void> initializeLocationBasedNotifications() async {
    if (state.locationStatus == LocationStatus.loading) return;

    emit(state.copyWith(locationStatus: LocationStatus.loading));

    try {
      final isNewDay = await _isNewDay();
      final refreshCheck = await _shouldRefresh();

      if (!isNewDay && !refreshCheck.shouldRefresh) {
        emit(state.copyWith(locationStatus: LocationStatus.success));
        return;
      }

      final isLocationEnabled = await LocationService.isLocationEnabled();
      final hasSavedLocation = await LocationService.hasSavedLocation();

      if (!isLocationEnabled) {
        emit(state.copyWith(locationStatus: LocationStatus.serviceDisabled));
        return;
      }

      final permission = await LocationService.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            locationStatus: LocationStatus.permissionDeniedForever,
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        final requested = await LocationService.requestPermission();

        if (requested == LocationPermission.denied) {
          emit(state.copyWith(locationStatus: LocationStatus.permissionDenied));
          return;
        }

        if (requested == LocationPermission.deniedForever) {
          emit(
            state.copyWith(
              locationStatus: LocationStatus.permissionDeniedForever,
            ),
          );
          return;
        }
      }

      try {
        final position =
            refreshCheck.cachedPosition ??
            await LocationService.getCurrentPosition();

        await LocationService.saveLastLocation(position);
        await refreshLocationBasedNotifications();
        await _saveRefreshMarker(position);
        return;
      } catch (e) {
        log('⚠️ Failed to get current location: $e');
      }

      if (hasSavedLocation) {
        await refreshLocationBasedNotifications();
        await _saveRefreshMarker(null);
        return;
      }

      emit(state.copyWith(locationStatus: LocationStatus.error));
    } catch (e, s) {
      log('❌ initializeLocationBasedNotifications error: $e');
      log('$s');
      emit(state.copyWith(locationStatus: LocationStatus.error));
    }
  }

  Future<bool> _isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRefreshDay = prefs.getString('last_refresh_day');
    final today = TimezoneService.currentTime()
        .toIso8601String()
        .split('T')
        .first;
    return lastRefreshDay != today;
  }

  Future<_RefreshCheckResult> _shouldRefresh() async {
    final prefs = await SharedPreferences.getInstance();

    final lastRefreshMillis = prefs.getInt('last_refresh_timestamp');
    if (lastRefreshMillis == null) {
      return const _RefreshCheckResult(true, null);
    }

    final lastRefreshTime = DateTime.fromMillisecondsSinceEpoch(
      lastRefreshMillis,
    );
    final now = TimezoneService.currentTime();
    if (now.difference(lastRefreshTime) >= const Duration(hours: 3)) {
      return const _RefreshCheckResult(true, null);
    }

    final lastLat = prefs.getDouble('last_refresh_lat');
    final lastLng = prefs.getDouble('last_refresh_lng');

    if (lastLat != null && lastLng != null) {
      try {
        final currentPosition = await LocationService.getCurrentPosition();
        final distance = Geolocator.distanceBetween(
          lastLat,
          lastLng,
          currentPosition.latitude,
          currentPosition.longitude,
        );
        if (distance >= 1000) {
          return _RefreshCheckResult(true, currentPosition);
        }
      } catch (_) {}
    }

    return const _RefreshCheckResult(false, null);
  }

  Future<void> _saveRefreshMarker(Position? position) async {
    final prefs = await SharedPreferences.getInstance();
    final now = TimezoneService.currentTime();

    await prefs.setInt('last_refresh_timestamp', now.millisecondsSinceEpoch);
    await prefs.setString(
      'last_refresh_day',
      now.toIso8601String().split('T').first,
    );

    if (position != null) {
      await prefs.setDouble('last_refresh_lat', position.latitude);
      await prefs.setDouble('last_refresh_lng', position.longitude);
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

class _RefreshCheckResult {
  final bool shouldRefresh;
  final Position? cachedPosition;
  const _RefreshCheckResult(this.shouldRefresh, this.cachedPosition);
}
