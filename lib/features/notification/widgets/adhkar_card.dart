import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../logic/cubits/notify_cubit.dart';

class AdhkarCard extends StatefulWidget {
  const AdhkarCard({super.key});

  @override
  State<AdhkarCard> createState() => _AdhkarCardState();
}

class _AdhkarCardState extends State<AdhkarCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = context.watch<NotifyCubit>().state;
    final notifyCubit = context.read<NotifyCubit>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey_800 : AppColors.primary_0,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _timeSettingRow(
            icon: Icons.wb_sunny_rounded,
            iconColor: AppColors.warning_200,
            title: S.of(context).azkarMorning,
            time: '${S.of(context).am} 06:30',
            enabled: state.azkarSabahEnabled,
            onChanged: (bool value) {
              notifyCubit.toggleAzkarSabah(value);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _timeSettingRow(
            icon: Icons.nights_stay_rounded,
            title: S.of(context).azkarEvening,
            time: '${S.of(context).pm} 05:30',
            enabled: state.azkarAlmasaaEnabled,
            // enabled: _eveningAdhkar,
            onChanged: (v) {
              notifyCubit.toggleAzkarAlmasaa(v);
            },
            iconColor: AppColors.primary_200,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _timeSettingRow(
            icon: Icons.nightlight,
            title: S.of(context).azkarSleeping,
            time: '${S.of(context).pm} 11:25',
            enabled: state.azkarAlnawmEnabled,
            onChanged: (v) {
              notifyCubit.toggleAzkarAlnawm(v);
            },
            iconColor: AppColors.primary_200,
          ),
        ],
      ),
    );
  }
}

Widget _timeSettingRow({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String time,
  required bool enabled,
  required ValueChanged<bool> onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              // color: AppColors.textDark,
            ),
          ),
        ),
        if (enabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  // color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12.5,
                    // color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        Transform.scale(
          scale: 0.85,
          child: Switch(value: enabled, onChanged: onChanged),
        ),
      ],
    ),
  );
}
