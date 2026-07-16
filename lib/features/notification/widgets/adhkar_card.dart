import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../logic/cubits/notify_cubit.dart';

class AdhkarCard extends StatelessWidget {
  const AdhkarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

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
      child: BlocBuilder<NotifyCubit, NotifyState>(
        builder: (context, state) {
          final notifyCubit = context.read<NotifyCubit>();

          return Column(
            children: [
              _timeSettingRow(
                icon: Icons.wb_sunny_rounded,
                iconColor: AppColors.warning_200,
                title: S.of(context).azkarMorning,
                time: _formatTime(context, state.azkarSabahTime),
                enabled: state.azkarSabahEnabled,
                onChanged: (value) {
                  notifyCubit.toggleAzkarSabah(value);
                },
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              _timeSettingRow(
                icon: Icons.nights_stay_rounded,
                iconColor: AppColors.primary_200,
                title: S.of(context).azkarEvening,
                time: _formatTime(context, state.azkarAlmasaaTime),
                enabled: state.azkarAlmasaaEnabled,
                onChanged: (value) {
                  notifyCubit.toggleAzkarAlmasaa(value);
                },
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              _timeSettingRow(
                icon: Icons.nightlight,
                iconColor: AppColors.primary_200,
                title: S.of(context).azkarSleeping,
                time: _formatTime(context, state.azkarAlnawmTime),
                enabled: state.azkarAlnawmEnabled,
                onChanged: (value) {
                  notifyCubit.toggleAzkarAlnawm(value);
                },
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              _timeSettingRow(
                icon: Icons.auto_awesome,
                iconColor: Colors.indigo,
                title: S.of(context).nightPrayer,
                time: _formatTime(context, state.nightPrayerTime),
                enabled: state.nightPrayerEnabled,
                onChanged: (value) {
                  notifyCubit.toggleNightPrayer(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) {
      return '--:--';
    }

    final locale = Localizations.localeOf(context).languageCode;

    return DateFormat(
      'hh:mm a',
      locale,
    ).format(dateTime);
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
  final hasTime = time != '--:--';

  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        if (enabled)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  hasTime
                      ? Icons.access_time_rounded
                      : Icons.location_off_rounded,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  hasTime ? time : '—',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: hasTime ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: enabled,
            onChanged: onChanged,
          ),
        ),
      ],
    ),
  );
}