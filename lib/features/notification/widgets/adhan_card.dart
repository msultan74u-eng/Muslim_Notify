import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_functions.dart';
import '../data/enum/prayer_type.dart';
import '../data/models/prayer_times_model.dart';
import '../logic/prayer_times_cubit/prayer_times_cubit.dart';
import '../logic/prayer_times_cubit/prayer_times_state.dart';
import 'adhan/card_shell.dart';
import 'adhan/loading_card.dart';
import 'adhan/prayer_row.dart';

/// Card that lists the 5 daily prayers, their times, and per-prayer
/// Adhan notification toggles.
class AdhanCard extends StatefulWidget {
  const AdhanCard({super.key});

  @override
  State<AdhanCard> createState() => _AdhanCardState();
}

class _AdhanCardState extends State<AdhanCard> {
  PrayerType? _expandedPrayer = PrayerType.fajr;

  void _setExpanded(PrayerType prayer, bool expand) {
    setState(() => _expandedPrayer = expand ? prayer : null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final prayerTimesState = context.watch<PrayerTimesCubit>().state;

    return switch (prayerTimesState) {
      PrayerTimesInitial() ||
      PrayerTimesLoading() => LoadingCard(isDark: isDark, height: 180),
      PrayerTimesError(:final message) => _ErrorCard(
        isDark: isDark,
        message: message,
      ),
      PrayerTimesLoaded(:final prayerTimes) => Stack(
        clipBehavior: Clip.none,
        children: [
          CardShell(
            isDark: isDark,
            child: Column(
              children: [
                for (final prayer in PrayerType.values)
                  PrayerRow(
                    key: ValueKey(prayer),
                    prayer: prayer,
                    time: _prayerTime(prayerTimes, prayer),
                    isExpanded: _expandedPrayer == prayer,
                    isLast: prayer == PrayerType.values.last,
                    onExpandToggle: (expand) => _setExpanded(prayer, expand),
                  ),
              ],
            ),
          ),
          if (prayerTimes.locationName != null &&
              prayerTimes.locationName!.isNotEmpty)
            Positioned(
              top: -12,
              right: 16,
              child: _LocationBadge(
                locationName: prayerTimes.locationName!,
                isDark: isDark,
              ),
            ),
        ],
      ),
    };
  }

  static DateTime _prayerTime(PrayerTimesModel times, PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => times.fajr,
      PrayerType.dhuhr => times.dhuhr,
      PrayerType.asr => times.asr,
      PrayerType.maghrib => times.maghrib,
      PrayerType.isha => times.isha,
    };
  }
}

class _LocationBadge extends StatelessWidget {
  final String locationName;
  final bool isDark;

  const _LocationBadge({required this.locationName, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 14,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            locationName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared card chrome (background, radius, shadow) used by all states.

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.isDark, required this.message});

  final bool isDark;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CardShell(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 8),
            const Text(
              'تعذر الحصول على مواقيت الصلاة',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<PrayerTimesCubit>().getTodayPrayerTimes(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
