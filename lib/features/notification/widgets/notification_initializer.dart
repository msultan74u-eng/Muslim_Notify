import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../nav_bar/bottom_nav_page.dart';
import '../../../core/utils/app_functions.dart';
import '../../../generated/l10n.dart';
import '../data/services/adhan_services/location_service.dart';
import '../data/services/timezone_service.dart';
import '../logic/notify_cubit/notify_cubit.dart';
import 'adhan/loading_card.dart';

/// نتيجة فحص _shouldRefresh: بترجع القرار + الـ Position اللي اتجابت
/// أثناء الفحص (لو اتجابت)، عشان نعيد استخدامها في الـ flow الرئيسي
/// بدل ما نطلب GPS تاني (توفير وقت + بطارية).
class _RefreshCheckResult {
  final bool shouldRefresh;
  final Position? cachedPosition;

  const _RefreshCheckResult(this.shouldRefresh, this.cachedPosition);
}

class NotificationInitializer extends StatefulWidget {
  const NotificationInitializer({super.key});

  @override
  State<NotificationInitializer> createState() {
    return _NotificationInitializerState();
  }
}

class _NotificationInitializerState extends State<NotificationInitializer>
    with WidgetsBindingObserver {
  bool _dialogIsShowing = false;

  // Prevent multiple initialization calls at the same time
  bool _isInitializing = false;

  // Prevent showing the app before location is ready
  bool _locationReady = false;

  // آخر مرة اتنفذ فيها _initializeNotifications فعليًا (تُسجَّل فورًا
  // بشكل synchronous قبل أي await، عشان تمنع أي race condition بين
  // initState و didChangeAppLifecycleState وقت الـ cold start)
  DateTime? _lastRunTime;

  // أقل فاصل زمني مسموح بين نداءين متتاليين لـ _initializeNotifications
  static const Duration _minCallGap = Duration(seconds: 2);

  // الحد الأدنى بين كل refresh وتاني (لتحديث GPS بس، مش للجدولة)
  static const Duration _minRefreshInterval = Duration(hours: 3);

  // الحد الأدنى للمسافة (بالمتر) عشان نعتبرها "تغيير موقع فعلي"
  static const double _minDistanceMeters = 1000; // 1 كم

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // تحسين UX: لو عندنا موقع محفوظ من قبل، نظهر الشاشة الرئيسية
    // فورًا من غير ما ننتظر كل فحوصات الـ refresh (يوم جديد / مسافة /
    // فاصل زمني). أي refresh فعلي هيحصل بعد كده في الخلفية من غير
    // ما يعطل عرض الشاشة.
    _checkInitialLocationReadiness();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeNotifications();
    }
  }

  /// فحص سريع (بدون أي عمليات ثقيلة زي GPS) لتحديد هل نقدر نعرض
  /// الشاشة الرئيسية فورًا وقت الإقلاع، وذلك لو عندنا موقع محفوظ
  /// بالفعل من نداء سابق.
  Future<void> _checkInitialLocationReadiness() async {
    final hasSavedLocation = await LocationService.hasSavedLocation();

    if (hasSavedLocation && mounted && !_locationReady) {
      setState(() {
        _locationReady = true;
      });
    }
  }

  Future<void> _initializeNotifications() async {
    if (!mounted || _isInitializing) {
      return;
    }

    // امنع أي نداء تاني خلال فترة قصيرة من آخر نداء فعلي (بيحصل غالبًا
    // وقت الـ cold start لما initState و didChangeAppLifecycleState(resumed)
    // يتنفذوا مع بعض تقريبًا). التسجيل هنا synchronous، فمفيش فرصة لـ
    // race condition زي اللي كانت بتحصل مع _isInitializing لوحده.
    final currentTime = DateTime.now();
    if (_lastRunTime != null &&
        currentTime.difference(_lastRunTime!) < _minCallGap) {
      debugPrint('⏭️ Skipping duplicate initialization call (too soon)');
      return;
    }
    _lastRunTime = currentTime;

    _isInitializing = true;

    try {
      // Initialize Prophet Salawat independently
      await context.read<NotifyCubit>().initializeProphetSalawatOnly();

      // "يوم جديد" لازم يفرض refresh دايمًا، بغض النظر عن باقي
      // شروط الـ throttle (3 ساعات / تغيير الموقع)
      final isNewDay = await _isNewDay();

      // فحص هل محتاجين refresh فعلي، وبيرجع كمان الـ Position لو
      // اتجابت أثناء فحص المسافة، عشان نعيد استخدامها تحت من غير ما
      // نطلب GPS مرة تانية.
      final refreshCheck = await _shouldRefresh();

      // لو مش أول مرة، ومش يوم جديد، وفحصنا ولقينا مفيش داعي لـ refresh،
      // منعملش حاجة
      if (_locationReady && !isNewDay && !refreshCheck.shouldRefresh) {
        return;
      }

      final isLocationEnabled = await LocationService.isLocationEnabled();

      final hasSavedLocation = await LocationService.hasSavedLocation();

      // Try to get the current location
      if (isLocationEnabled) {
        try {
          // لو عندنا Position اتجابت بالفعل من _shouldRefresh نستخدمها،
          // وإلا نطلبها من جديد (أول مرة، أو لو مفيش last lat/lng محفوظة)
          final position =
              refreshCheck.cachedPosition ??
              await LocationService.getCurrentPosition();

          await LocationService.saveLastLocation(position);

          await context.read<NotifyCubit>().refreshLocationBasedNotifications();

          await _saveRefreshMarker(position);

          if (mounted && !_locationReady) {
            setState(() {
              _locationReady = true;
            });
          }

          return;
        } catch (e) {
          debugPrint('⚠️ Failed to get current location: $e');
        }
      }

      // Use the last saved location if available
      if (hasSavedLocation) {
        await context.read<NotifyCubit>().refreshLocationBasedNotifications();

        await _saveRefreshMarker(null);

        if (mounted && !_locationReady) {
          setState(() {
            _locationReady = true;
          });
        }

        return;
      }

      // No current location and no saved location
      // نعتبر الجدولة اتظبطت (بالـ default) عشان مانعلقش على شاشة اللودينج
      // للأبد لو المستخدم قفل الـ dialog من غير ما يفعّل الموقع
      if (mounted && !_locationReady) {
        setState(() {
          _locationReady = true;
        });
      }

      await _showLocationDialog();
    } catch (e, s) {
      debugPrint('❌ Notification initialization error: $e');

      debugPrint('$s');
    } finally {
      _isInitializing = false;
    }
  }

  /// فحص مستقل: هل دخلنا يوم جديد؟ (بيستخدم دايمًا نفس مصدر الوقت
  /// المستخدم في باقي النظام لحساب مواقيت الصلاة)
  Future<bool> _isNewDay() async {
    final prefs = await SharedPreferences.getInstance();

    final lastRefreshDay = prefs.getString('last_refresh_day');
    final today = TimezoneService.currentTime()
        .toIso8601String()
        .split('T')
        .first;

    final isNewDay = lastRefreshDay != today;

    if (isNewDay) {
      debugPrint('🔄 New day detected → refresh needed');
    }

    return isNewDay;
  }

  /// يحدد هل محتاجين فعلياً نعمل refresh كامل (GPS + إعادة جدولة) ولا لأ
  /// ملحوظة: فحص "يوم جديد" اتفصل بره الدالة دي (_isNewDay) عشان
  /// يتفحص بشكل مستقل وميتأثرش بباقي الشروط
  ///
  /// بترجع _RefreshCheckResult بدل bool عادي، عشان لو طلبنا GPS هنا
  /// (لقياس المسافة) نقدر نعيد استخدام نفس الـ Position تحت في
  /// _initializeNotifications من غير ما نطلبها تاني.
  Future<_RefreshCheckResult> _shouldRefresh() async {
    final prefs = await SharedPreferences.getInstance();

    // عدّى وقت كافي من آخر refresh؟
    final lastRefreshMillis = prefs.getInt('last_refresh_timestamp');
    if (lastRefreshMillis == null) {
      return const _RefreshCheckResult(true, null); // مفيش سجل قبل كده
    }
    final lastRefreshTime = DateTime.fromMillisecondsSinceEpoch(
      lastRefreshMillis,
    );
    final now = TimezoneService.currentTime();
    if (now.difference(lastRefreshTime) >= _minRefreshInterval) {
      debugPrint('🔄 Refresh interval elapsed → refresh needed');
      return const _RefreshCheckResult(true, null);
    }

    // الموقع اتغيّر بشكل ملحوظ؟
    final lastLat = prefs.getDouble('last_refresh_lat');
    final lastLng = prefs.getDouble('last_refresh_lng');

    if (lastLat != null && lastLng != null) {
      try {
        final currentPosition = await LocationService.getCurrentPosition();
        final distance = Geolocator.distanceBetween(
          lastLat,
          lastLng,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        if (distance >= _minDistanceMeters) {
          debugPrint(
            '🔄 Location changed significantly ($distance m) → refresh needed',
          );
          // بنرجّع الـ Position اللي جبناها هنا عشان نعيد استخدامها
          // تحت ونوفر نداء GPS تاني.
          return _RefreshCheckResult(true, currentPosition);
        }
      } catch (_) {
        // لو فشل الحصول على الموقع الحالي هنا، منعملش refresh بالغلط
        // (هيتلقط بره لو GPS فعلاً معطل)
      }
    }

    debugPrint('⏭️ No refresh needed — using cached schedule');
    return const _RefreshCheckResult(false, null);
  }

  /// يحفظ وقت وموقع آخر refresh فعلي
  Future<void> _saveRefreshMarker(Position? position) async {
    final prefs = await SharedPreferences.getInstance();

    final now = TimezoneService.currentTime();

    await prefs.setInt('last_refresh_timestamp', now.millisecondsSinceEpoch);

    await prefs.setString(
      'last_refresh_day',
      now.toIso8601String().split('T').first,
    );

    if (position != null) {
      await prefs.setDouble('last_refresh_lat', position.latitude);
      await prefs.setDouble('last_refresh_lng', position.longitude);
    }
  }

  Future<void> _showLocationDialog() async {
    if (_dialogIsShowing || !mounted) {
      return;
    }

    _dialogIsShowing = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).locationRequired),

          content: Text(S.of(context).locationDialogContent),

          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await LocationService.openLocationSettings();
              },

              child: Text(S.of(context).openSettings),
            ),
          ],
        );
      },
    );

    _dialogIsShowing = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    if (!_locationReady) {
      return Scaffold(
        body: Center(child: LoadingCardMain(isDark: isDark, height: 280)),
      );
    }

    return const BottomNavPage();
  }
}
