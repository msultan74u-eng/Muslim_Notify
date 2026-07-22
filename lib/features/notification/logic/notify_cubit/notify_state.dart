part of 'notify_cubit.dart';

class NotifyState {
  /// Used to distinguish between:
  /// 1. No value was provided → keep the old value.
  /// 2. null was explicitly provided → clear the value.
  static const _unset = Object();

  /// 1- Salawat notification
  final bool salawatEnabled;
  final int salawatIntervalIndex;
  final bool fridayBoost;

  /// 2- Azkar Sabah notification
  final bool azkarSabahEnabled;
  final DateTime? azkarSabahTime;

  /// 3- Azkar Almasaa notification
  final bool azkarAlmasaaEnabled;
  final DateTime? azkarAlmasaaTime;

  /// 4- Azkar Alnawm notification
  final bool azkarAlnawmEnabled;
  final DateTime? azkarAlnawmTime;

  /// 5- Night Prayer notification
  final bool nightPrayerEnabled;
  final DateTime? nightPrayerTime;

  /// 6- Prayer Reminder notification
  final bool prayerReminderEnable;

  /// 7- Prayer Adhan notification
  // 1- Fajr Adhan
  final bool fajrAdhanEnabled;
  // 2- Dhuhr Adhan
  final bool dhuhrAdhanEnabled;
  // 3- Asr Adhan
  final bool asrAdhanEnabled;
  // 4- Maghrib Adhan
  final bool maghribAdhanEnabled;
  // 5- Isha Adhan
  final bool ishaAdhanEnabled;

  const NotifyState({
    /// 1
    required this.salawatEnabled,
    required this.salawatIntervalIndex,
    required this.fridayBoost,

    /// 2
    required this.azkarSabahEnabled,
    required this.azkarSabahTime,

    /// 3
    required this.azkarAlmasaaEnabled,
    required this.azkarAlmasaaTime,

    /// 4
    required this.azkarAlnawmEnabled,
    required this.azkarAlnawmTime,

    /// 5
    required this.nightPrayerEnabled,
    required this.nightPrayerTime,

    /// 6
    required this.prayerReminderEnable,

    /// 7
    // 1- Fajr Adhan
    required this.fajrAdhanEnabled,
    // 2- Dhuhr Adhan
    required this.dhuhrAdhanEnabled,
    // 3- Asr Adhan
    required this.asrAdhanEnabled,
    // 4- Maghrib Adhan
    required this.maghribAdhanEnabled,
    // 5- Isha Adhan
    required this.ishaAdhanEnabled,
  });

  factory NotifyState.initial() {
    return const NotifyState(
      // 1
      salawatEnabled: true,
      salawatIntervalIndex: 0,
      fridayBoost: true,

      // 2
      azkarSabahEnabled: true,
      azkarSabahTime: null,

      // 3
      azkarAlmasaaEnabled: true,
      azkarAlmasaaTime: null,

      // 4
      azkarAlnawmEnabled: true,
      azkarAlnawmTime: null,

      // 5
      nightPrayerEnabled: true,
      nightPrayerTime: null,

      // 6
      prayerReminderEnable: true,

      // 7
      fajrAdhanEnabled: true,
      dhuhrAdhanEnabled: true,
      asrAdhanEnabled: true,
      maghribAdhanEnabled: true,
      ishaAdhanEnabled: true,
    );
  }

  NotifyState copyWith({
    // 1
    bool? salawatEnabled,
    int? salawatIntervalIndex,
    bool? fridayBoost,

    // 2
    bool? azkarSabahEnabled,
    Object? azkarSabahTime = _unset,

    // 3
    bool? azkarAlmasaaEnabled,
    Object? azkarAlmasaaTime = _unset,

    // 4
    bool? azkarAlnawmEnabled,
    Object? azkarAlnawmTime = _unset,

    // 5
    bool? nightPrayerEnabled,
    Object? nightPrayerTime = _unset,

    // 6
    bool? prayerReminderEnable,

    // 7
    bool? fajrAdhanEnabled,
    bool? dhuhrAdhanEnabled,
    bool? asrAdhanEnabled,
    bool? maghribAdhanEnabled,
    bool? ishaAdhanEnabled,
  }) {
    return NotifyState(
      // 1
      salawatEnabled: salawatEnabled ?? this.salawatEnabled,
      salawatIntervalIndex: salawatIntervalIndex ?? this.salawatIntervalIndex,
      fridayBoost: fridayBoost ?? this.fridayBoost,

      // 2
      azkarSabahEnabled: azkarSabahEnabled ?? this.azkarSabahEnabled,
      azkarSabahTime: azkarSabahTime == _unset
          ? this.azkarSabahTime
          : azkarSabahTime as DateTime?,

      // 3
      azkarAlmasaaEnabled: azkarAlmasaaEnabled ?? this.azkarAlmasaaEnabled,
      azkarAlmasaaTime: azkarAlmasaaTime == _unset
          ? this.azkarAlmasaaTime
          : azkarAlmasaaTime as DateTime?,

      // 4
      azkarAlnawmEnabled: azkarAlnawmEnabled ?? this.azkarAlnawmEnabled,
      azkarAlnawmTime: azkarAlnawmTime == _unset
          ? this.azkarAlnawmTime
          : azkarAlnawmTime as DateTime?,

      // 5
      nightPrayerEnabled: nightPrayerEnabled ?? this.nightPrayerEnabled,
      nightPrayerTime: nightPrayerTime == _unset
          ? this.nightPrayerTime
          : nightPrayerTime as DateTime?,

      // 6
      prayerReminderEnable: prayerReminderEnable ?? this.prayerReminderEnable,

      // 7
      fajrAdhanEnabled: fajrAdhanEnabled ?? this.fajrAdhanEnabled,
      dhuhrAdhanEnabled: dhuhrAdhanEnabled ?? this.dhuhrAdhanEnabled,
      asrAdhanEnabled: asrAdhanEnabled ?? this.asrAdhanEnabled,
      maghribAdhanEnabled: maghribAdhanEnabled ?? this.maghribAdhanEnabled,
      ishaAdhanEnabled: ishaAdhanEnabled ?? this.ishaAdhanEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 1
      'salawatEnabled': salawatEnabled,
      'salawatIntervalIndex': salawatIntervalIndex,
      'fridayBoost': fridayBoost,

      // 2
      'azkarSabahEnabled': azkarSabahEnabled,
      'azkarSabahTime': azkarSabahTime?.toIso8601String(),

      // 3
      'azkarAlmasaaEnabled': azkarAlmasaaEnabled,
      'azkarAlmasaaTime': azkarAlmasaaTime?.toIso8601String(),

      // 4
      'azkarAlnawmEnabled': azkarAlnawmEnabled,
      'azkarAlnawmTime': azkarAlnawmTime?.toIso8601String(),

      // 5
      'nightPrayerEnabled': nightPrayerEnabled,
      'nightPrayerTime': nightPrayerTime?.toIso8601String(),

      // 6
      'prayerReminderEnable': prayerReminderEnable,

      // 7
      'fajrAdhanEnabled': fajrAdhanEnabled,
      'dhuhrAdhanEnabled': dhuhrAdhanEnabled,
      'asrAdhanEnabled': asrAdhanEnabled,
      'maghribAdhanEnabled': maghribAdhanEnabled,
      'ishaAdhanEnabled': ishaAdhanEnabled,
    };
  }

  factory NotifyState.fromMap(Map<String, dynamic> map) {
    return NotifyState(
      // 1
      salawatEnabled: map['salawatEnabled'] ?? true,
      salawatIntervalIndex: map['salawatIntervalIndex'] ?? 0,
      fridayBoost: map['fridayBoost'] ?? true,

      // 2
      azkarSabahEnabled: map['azkarSabahEnabled'] ?? true,
      azkarSabahTime: map['azkarSabahTime'] != null
          ? DateTime.parse(map['azkarSabahTime'])
          : null,

      // 3
      azkarAlmasaaEnabled: map['azkarAlmasaaEnabled'] ?? true,
      azkarAlmasaaTime: map['azkarAlmasaaTime'] != null
          ? DateTime.parse(map['azkarAlmasaaTime'])
          : null,

      // 4
      azkarAlnawmEnabled: map['azkarAlnawmEnabled'] ?? true,
      azkarAlnawmTime: map['azkarAlnawmTime'] != null
          ? DateTime.parse(map['azkarAlnawmTime'])
          : null,

      // 5
      nightPrayerEnabled: map['nightPrayerEnabled'] ?? true,
      nightPrayerTime: map['nightPrayerTime'] != null
          ? DateTime.parse(map['nightPrayerTime'])
          : null,

      // 6
      prayerReminderEnable: map['prayerReminderEnable'] ?? true,

      // 7
      fajrAdhanEnabled: map['fajrAdhanEnabled'] ?? true,
      dhuhrAdhanEnabled: map['dhuhrAdhanEnabled'] ?? true,
      asrAdhanEnabled: map['asrAdhanEnabled'] ?? true,
      maghribAdhanEnabled: map['maghribAdhanEnabled'] ?? true,
      ishaAdhanEnabled: map['ishaAdhanEnabled'] ?? true,
    );
  }
}
