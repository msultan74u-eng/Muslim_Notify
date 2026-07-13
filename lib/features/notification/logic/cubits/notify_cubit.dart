import 'dart:developer';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/notify_manager.dart';

part 'notify_state.dart';

class NotifyCubit extends HydratedCubit<NotifyState> {
  NotifyCubit() : super(NotifyState.initial());

  final NotifyManager _notifyManager = NotifyManager();

  /// * initial state of notify
  Future<void> initializeNotifications() async {
    log("🚀 initializeNotifications CALLED");

    await _updateProphetSalawatNotification(state.salawatEnabled);
    await _updateAzkarAlmasaaNotification(state.azkarAlmasaaEnabled);
    await _updateAzkarSabahNotification(state.azkarSabahEnabled);
    await _updateAzkarAlnawmNotification(state.azkarAlnawmEnabled);
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
  //
  // 2-  TODo azkar_Sabah
  //

  // 3- Azkar Almasaa notification
  Future<void> _updateAzkarAlmasaaNotification(bool enabled) async {
    if (enabled) {
      await _notifyManager.enableNotifications(NotificationType.azkarAlmasaa);
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarAlmasaa);
    }
  }

  // 4- Azkar Sabah notification
  Future<void> _updateAzkarSabahNotification(bool enabled) async {
    if (enabled) {
      await _notifyManager.enableNotifications(NotificationType.azkarSabah);
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarSabah);
    }
  }

  // 5- Azkar Alnawm notification
  Future<void> _updateAzkarAlnawmNotification(bool enabled) async {
    if (enabled) {
      await _notifyManager.enableNotifications(NotificationType.azkarAlnawm);
    } else {
      await _notifyManager.disableNotifications(NotificationType.azkarAlnawm);
    }
  }

  /// * Toggle methode of notify
  // 1- Prophet Salawat notification
  Future<void> toggleProphetSalawat(bool enabled) async {
    emit(state.copyWith(salawatEnabled: enabled));
    await _updateProphetSalawatNotification(enabled);
  }
  //
  // 2-  TODo azkar_Sabah
  //

  // 3- Azkar Almasaa notification
  Future<void> toggleAzkarAlmasaa(bool enabled) async {
    emit(state.copyWith(azkarAlmasaaEnabled: enabled));
    await _updateAzkarAlmasaaNotification(enabled);
  }

  // 4- Azkar Sabah notification
  Future<void> toggleAzkarSabah(bool enabled) async {
    emit(state.copyWith(azkarSabahEnabled: enabled));
    await _updateAzkarSabahNotification(enabled);
  }

  // 5- Azkar Alnawm notification
  Future<void> toggleAzkarAlnawm(bool enabled) async {
    emit(state.copyWith(azkarAlnawmEnabled: enabled));
    await _updateAzkarAlnawmNotification(enabled);
  }

  ///
  ///
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

  // Hydrated

  @override
  NotifyState? fromJson(Map<String, dynamic> json) {
    return NotifyState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(NotifyState state) {
    return state.toMap();
  }
}
