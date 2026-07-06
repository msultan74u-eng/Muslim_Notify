import 'package:flutter/material.dart';
import 'package:muslim_notify/features/notification/widgets/switch_row.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';

class DhikrCard extends StatefulWidget {
  const DhikrCard({super.key});

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  final _dhikrOptions = ['كل 30 دقيقة', 'كل ساعة', 'كل ساعتين', 'كل 3 ساعات'];
  final bool _dhikrEnabled = true;
  final int _dhikrIntervalIndex = 1;
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
            label: 'تفعيل تذكير الذكر',
            value: _dhikrEnabled,
            onChanged: (v) {},
          ),
          if (_dhikrEnabled) ...[
            const SizedBox(height: 14),
            const Text(
              'كل قد إيه؟',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_dhikrOptions.length, (i) {
                final selected = _dhikrIntervalIndex == i;
                return GestureDetector(
                  onTap: () {},
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary_200 : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _dhikrOptions[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFC9A24B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFC9A24B).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.nightlight_round,
                    size: 16,
                    color: AppColors.primary_200,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'عدم الإزعاج من 11 م إلى 5 ص',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,

                    child: Switch(
                      value: true,
                      activeThumbColor: Color(0xFFC9A24B),
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
