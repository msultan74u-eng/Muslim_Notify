import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muslim_notify/features/notification/widgets/switch_row.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../logic/notify_cubit/notify_cubit.dart';

class SalawatCard extends StatefulWidget {
  const SalawatCard({super.key});

  @override
  State<SalawatCard> createState() => _SalawatCardState();
}

class _SalawatCardState extends State<SalawatCard> {
  List<String> _getIntervalOptions(BuildContext context) {
    final s = S.of(context);
    return [
      s.every15Minutes,
      s.every20Minutes,
      s.every30Minutes,
      s.every1Hour,
      s.every2Hours,
      s.every3Hours,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final s = S.of(context);
    final state = context.watch<NotifyCubit>().state;
    final notifyCubit = context.read<NotifyCubit>();

    final int selectedIndex = state.salawatIntervalIndex;
    final intervalOptions = _getIntervalOptions(context);

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchRow(
            label: s.prophetEnable,
            value: state.salawatEnabled,
            onChanged: notifyCubit.toggleProphetSalawat,
          ),
          if (state.salawatEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${s.repeatEvery} ', style: const TextStyle(fontSize: 13)),
                Text(
                  intervalOptions[selectedIndex],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary_200,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary_300,
                thumbColor: AppColors.primary_200,
                inactiveTrackColor: AppColors.grey_300.withValues(alpha: 0.5),
                overlayColor: AppColors.primary_200.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: selectedIndex.toDouble(),
                min: 0,
                max: (intervalOptions.length - 1).toDouble(),
                divisions: intervalOptions.length - 1,
                label: intervalOptions[selectedIndex],
                onChanged: (value) {
                  notifyCubit.changeSalawatInterval(value.toInt());
                },
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A24B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFC9A24B).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFC9A24B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.fridayBoost,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: state.fridayBoost,
                          activeThumbColor: const Color(0xFFC9A24B),
                          onChanged: notifyCubit.changeFridayBoost,
                        ),
                      ),
                    ],
                  ),
                  if (state.fridayBoost) ...[
                    const SizedBox(height: 4),
                    Text(
                      s.fridayBoostDesc,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
