import 'package:flutter/material.dart';
import 'package:muslim_notify/core/themes/app_colors.dart';
import 'package:muslim_notify/core/themes/app_text_styles.dart';

import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../widgets/adhan_w_page/equalizer_bars.dart';
import '../widgets/adhan_w_page/pulsing_ripple_Icon.dart';

class AdhanPage extends StatelessWidget {
  const AdhanPage({super.key, required this.prayerType});

  final String prayerType;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);
    final s = S.of(context);
    final bodyTextColor = theme.textTheme.bodyMedium?.color?.withValues(
      alpha: 0.75,
    );
    return Scaffold(
      backgroundColor: isDark ? AppColors.sky_200 : AppColors.primary_0,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const PulsingRippleIcon(),
            const SizedBox(height: 16),
            Text(
              prayerType,
              style: AppTextStyles.headingH2.copyWith(
                color: AppColors.darkFillColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.adhanTimeNow,
              style: AppTextStyles.mRegular.copyWith(color: bodyTextColor),
            ),
            const SizedBox(height: 28),
            const EqualizerBars(),
            const SizedBox(height: 6),
            Text(
              s.adhanIsPlaying,
              style: AppTextStyles.mRegular.copyWith(color: bodyTextColor),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
