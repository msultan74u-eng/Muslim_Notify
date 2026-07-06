import 'package:flutter/material.dart';
import 'package:muslim_notify/features/notification/widgets/switch_row.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';

class SalawatCard extends StatefulWidget {
  const SalawatCard({super.key});

  @override
  State<SalawatCard> createState() => _SalawatCardState();
}

class _SalawatCardState extends State<SalawatCard> {
  bool _salawatEnabled = true;
  double _salawatHours = 3;
  bool _fridayBoost = true;

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchRow(
            label: 'تفعيل تذكير الصلاة على النبي',
            value: _salawatEnabled,
            onChanged: (v) => setState(() => _salawatEnabled = v),
          ),
          if (_salawatEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('كل ', style: TextStyle(fontSize: 13)),
                Text(
                  '${_salawatHours.round()} ساعة',
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
                value: _salawatHours,
                min: 1,
                max: 8,
                divisions: 7,
                onChanged: (v) => setState(() => _salawatHours = v),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFC9A24B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFC9A24B).withValues(alpha: 0.3),
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
                      const Expanded(
                        child: Text(
                          'زيادة التذكيرات يوم الجمعة',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _fridayBoost,
                          activeThumbColor: Color(0xFFC9A24B),
                          onChanged: (v) => setState(() => _fridayBoost = v),
                        ),
                      ),
                    ],
                  ),
                  if (_fridayBoost) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'سُنّة الإكثار من الصلاة على النبي ﷺ يوم الجمعة',
                      style: TextStyle(fontSize: 11.5),
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
