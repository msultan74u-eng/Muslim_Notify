import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'bottom_nav_page.dart';
import 'core/themes/theme_cubit/theme_cubit.dart';
import 'core/themes/theme_data/theme_data_dark.dart';
import 'core/themes/theme_data/theme_data_light.dart';
import 'features/language/logic/lang_cubit/lang_cubit.dart';
import 'features/language/logic/lang_cubit/lang_state.dart';
import 'features/notification/data/services/adhan_services/location_service.dart';
import 'features/notification/data/services/local_notification_services.dart';
import 'features/notification/data/services/work_manager_service.dart';
import 'features/notification/logic/cubits/notify_cubit.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Hydrated Bloc Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );

  /// Initialize Notification Services and WorkManager
  await Future.wait([
    LocalNotificationServices.init(),
    WorkManagerService().init(),
  ]);

  /// Create NotifyCubit
  final notifyCubit = NotifyCubit();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LangCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider.value(value: notifyCubit),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langState = context.watch<LangCubit>().state;
    final themeMode = context.watch<ThemeCubit>().state;

    if (langState is! LangLoaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// Localization
      locale: langState.locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      /// Theme
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,

      /// App Entry Point
      home: const NotificationInitializer(),
    );
  }
}

///
/// Notification Initializer
///
class NotificationInitializer extends StatefulWidget {
  const NotificationInitializer({super.key});

  @override
  State<NotificationInitializer> createState() =>
      _NotificationInitializerState();
}

class _NotificationInitializerState extends State<NotificationInitializer>
    with WidgetsBindingObserver {
  bool _dialogIsShowing = false;

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

  /// Called when the app returns from the device settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeNotifications();
    }
  }

  Future<void> _initializeNotifications() async {
    if (!mounted) return;

    try {
      final isLocationEnabled = await LocationService.isLocationEnabled();
      final hasSavedLocation = await LocationService.hasSavedLocation();

      // 1️⃣ GPS enabled
      if (isLocationEnabled) {
        try {
          final position = await LocationService.getCurrentPosition();
          await LocationService.saveLastLocation(position);
          await context.read<NotifyCubit>().initializeNotifications();
          return;
        } catch (e) {
          // If current location fails, try fallback
        }
      }

      // 2️⃣ GPS disabled but saved location exists
      if (hasSavedLocation) {
        await context.read<NotifyCubit>().initializeNotifications();
        return;
      }

      // 3️⃣ No GPS + no saved location
      await _showLocationDialog();
    } catch (e, s) {
      debugPrint('❌ Notification initialization error: $e');
      debugPrint('$s');
    }
  }

  Future<void> _showLocationDialog() async {
    if (_dialogIsShowing || !mounted) return;

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
