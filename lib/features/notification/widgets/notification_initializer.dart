import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bottom_nav_page.dart';
import '../../../generated/l10n.dart';
import '../data/services/adhan_services/location_service.dart';
import '../logic/cubits/notify_cubit.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

  Future<void> _initializeNotifications() async {
    if (!mounted || _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      // ← سطر جديد: يتنفذ دايمًا، بغض النظر عن حالة الموقع
      await context.read<NotifyCubit>().initializeProphetSalawatOnly();

      final isLocationEnabled = await LocationService.isLocationEnabled();
      final hasSavedLocation = await LocationService.hasSavedLocation();

      if (isLocationEnabled) {
        try {
          final position = await LocationService.getCurrentPosition();
          await LocationService.saveLastLocation(position);
          await context.read<NotifyCubit>().refreshLocationBasedNotifications();
          return;
        } catch (e) {
          // fallback
        }
      }

      if (hasSavedLocation) {
        await context.read<NotifyCubit>().refreshLocationBasedNotifications();
        return;
      }

      await _showLocationDialog();
    } catch (e, s) {
      debugPrint('❌ Notification initialization error: $e');
      debugPrint('$s');
    } finally {
      _isInitializing = false;
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
    return const BottomNavPage();
  }
}
