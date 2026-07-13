part of 'notify_cubit.dart';

class NotifyState {
  /// 1- salawat notification
  final bool salawatEnabled;
  final int salawatIntervalIndex;
  final bool fridayBoost;

  /// 2-
  // TODo
  /// 3- azkar almasaa notification
  final bool azkarAlmasaaEnabled;

  /// 4- azkar almasaa notification
  final bool azkarSabahEnabled;

  /// 5- azkar alnawm notification
  final bool azkarAlnawmEnabled;

  const NotifyState({
    // 1
    required this.salawatEnabled,
    required this.salawatIntervalIndex,
    required this.fridayBoost,
    // 3
    required this.azkarAlmasaaEnabled,
    // 4
    required this.azkarSabahEnabled,
    // 5
    required this.azkarAlnawmEnabled,
  });

  factory NotifyState.initial() {
    return const NotifyState(
      // 1
      salawatEnabled: true,
      salawatIntervalIndex: 0,
      fridayBoost: true,
      // 3
      azkarAlmasaaEnabled: true,
      // 4
      azkarSabahEnabled: true,
      // 5
      azkarAlnawmEnabled: true,
    );
  }

  NotifyState copyWith({
    // 1
    bool? salawatEnabled,
    int? salawatIntervalIndex,
    bool? fridayBoost,
    // 2
    ///
    // 3
    bool? azkarAlmasaaEnabled,
    // 4
    bool? azkarSabahEnabled,
    // 5
    bool? azkarAlnawmEnabled,
  }) {
    return NotifyState(
      // 1
      salawatEnabled: salawatEnabled ?? this.salawatEnabled,
      salawatIntervalIndex: salawatIntervalIndex ?? this.salawatIntervalIndex,
      fridayBoost: fridayBoost ?? this.fridayBoost,
      // 2
      ///
      // 3
      azkarAlmasaaEnabled: azkarAlmasaaEnabled ?? this.azkarAlmasaaEnabled,
      // 4
      azkarSabahEnabled: azkarSabahEnabled ?? this.azkarSabahEnabled,
      // 5
      azkarAlnawmEnabled: azkarAlnawmEnabled ?? this.azkarAlnawmEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 1
      'salawatEnabled': salawatEnabled,
      'salawatIntervalIndex': salawatIntervalIndex,
      'fridayBoost': fridayBoost,
      // 2
      ///
      // 3
      'azkarAlmasaaEnabled': azkarAlmasaaEnabled,
      // 4
      'azkarSabahEnabled': azkarSabahEnabled,
      // 5
      'azkarAlnawmEnabled': azkarAlnawmEnabled,
    };
  }

  factory NotifyState.fromMap(Map<String, dynamic> map) {
    return NotifyState(
      // 1
      salawatEnabled: map['salawatEnabled'] ?? true,
      salawatIntervalIndex: map['salawatIntervalIndex'] ?? 0,
      fridayBoost: map['fridayBoost'] ?? true,
      // 2
      ///
      // 3
      azkarAlmasaaEnabled: map['azkarAlmasaaEnabled'] ?? true,
      // 4
      azkarSabahEnabled: map['azkarSabahEnabled'] ?? true,
      // 5
      azkarAlnawmEnabled: map['azkarAlnawmEnabled'] ?? true,
    );
  }
}
