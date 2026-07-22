import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../generated/l10n.dart';
import '../../data/enum/prayer_type.dart';
import '../../logic/notify_cubit/notify_cubit.dart';
import '../switch_row.dart';

class PrayerRow extends StatelessWidget {
  const PrayerRow({
    super.key,
    required this.prayer,
    required this.time,
    required this.isExpanded,
    required this.isLast,
    required this.onExpandToggle,
  });

  final PrayerType prayer;
  final DateTime time;
  final bool isExpanded;
  final bool isLast;
  final ValueChanged<bool> onExpandToggle;

  String _title(BuildContext context) {
    return switch (prayer) {
      PrayerType.fajr => S.of(context).fajr,
      PrayerType.dhuhr => S.of(context).dhuhr,
      PrayerType.asr => S.of(context).asr,
      PrayerType.maghrib => S.of(context).maghrib,
      PrayerType.isha => S.of(context).ishaa,
    };
  }

  bool _enabledIn(NotifyState state) {
    return switch (prayer) {
      PrayerType.fajr => state.fajrAdhanEnabled,
      PrayerType.dhuhr => state.dhuhrAdhanEnabled,
      PrayerType.asr => state.asrAdhanEnabled,
      PrayerType.maghrib => state.maghribAdhanEnabled,
      PrayerType.isha => state.ishaAdhanEnabled,
    };
  }

  ///   todo →     refactor this function
  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'م' : 'ص';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<NotifyCubit, bool>(
      (cubit) => _enabledIn(cubit.state),
    );

    final title = _title(context);
    final subtitle = enabled ? S.of(context).haramAzan : 'الإشعار متوقف';

    final isDark = context.isDarkMode;

    return Column(
      children: [
        InkWell(
          onTap: () => onExpandToggle(!isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 1- Icon dot → Enabled/Disabled
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? AppColors.warning_100
                        : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: enabled ? null : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatTime(time),
                  semanticsLabel: '${_title(context)} ${_formatTime(time)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? (isDark ? Colors.white : AppColors.primary_300)
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: enabled,
                    activeThumbColor: AppColors.primary_300,
                    onChanged: (value) => context
                        .read<NotifyCubit>()
                        .togglePrayerAdhanByType(prayer, value),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _DropdownRow(
                  label: S.of(context).adhanVoice,
                  value: S.of(context).haramAzan,
                ),
                const SizedBox(height: 10),
                SwitchRow(
                  label: S.of(context).rememberAzam,
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          crossFadeState: isExpanded && enabled
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          const Icon(Icons.expand_more_rounded, size: 18),
        ],
      ),
    );
  }
}
