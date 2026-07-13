import 'package:flutter/material.dart';
import 'package:muslim_notify/features/notification/widgets/switch_row.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';

enum PrayerType { fajr, dhuhr, asr, maghrib, isha }

class AdhanCard extends StatefulWidget {
  const AdhanCard({super.key});

  @override
  State<AdhanCard> createState() => _AdhanCardState();
}

class _AdhanCardState extends State<AdhanCard> {
  final Map<PrayerType, bool> _adhanEnabled = {
    PrayerType.fajr: true,
    PrayerType.dhuhr: true,
    PrayerType.asr: true,
    PrayerType.maghrib: true,
    PrayerType.isha: true,
  };
  late PrayerType _expandedPrayer = PrayerType.fajr;

  String prayerTitle(BuildContext context, PrayerType prayer) {
    switch (prayer) {
      case PrayerType.fajr:
        return S.of(context).fajr;
      case PrayerType.dhuhr:
        return S.of(context).dhuhr;
      case PrayerType.asr:
        return S.of(context).asr;
      case PrayerType.maghrib:
        return S.of(context).maghrib;
      case PrayerType.isha:
        return S.of(context).ishaa;
    }
  }

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
      child: Column(
        children: _adhanEnabled.keys.map((prayer) {
          final isLast = prayer == _adhanEnabled.keys.last;
          final enabled = _adhanEnabled[prayer]!;
          final expanded = _expandedPrayer == prayer;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedPrayer = (expanded ? null : prayer)!;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: enabled ? AppColors.warning_100 : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayerTitle(context, prayer),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              enabled
                                  ? S.of(context).haramAzan
                                  : 'الإشعار متوقف',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: enabled ? null : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          // color: AppColors.grey_50,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: enabled,
                          activeThumbColor: AppColors.primary_300,
                          onChanged: (v) {},
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
                      _dropdownRow(
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
                crossFadeState: (expanded && enabled)
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

Widget _dropdownRow({required String label, required String value}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
    child: Row(
      children: [
        Icon(Icons.graphic_eq_rounded, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        const Icon(Icons.expand_more_rounded, size: 18),
      ],
    ),
  );
}
