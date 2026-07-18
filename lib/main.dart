import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'core/themes/theme_cubit/theme_cubit.dart';
import 'core/themes/theme_data/theme_data_dark.dart';
import 'core/themes/theme_data/theme_data_light.dart';
import 'features/language/logic/lang_cubit/lang_cubit.dart';
import 'features/language/logic/lang_cubit/lang_state.dart';
import 'features/notification/data/services/local_notification_services.dart';
import 'features/notification/data/services/work_manager_service.dart';
import 'features/notification/logic/cubits/notify_cubit.dart';
import 'features/notification/widgets/notification_initializer.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hydrated Bloc Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );

  // Initialize Notification Services and WorkManager
  await Future.wait([
    LocalNotificationServices.init(),
    WorkManagerService().init(),
  ]);

  // Create NotifyCubit
  final notifyCubit = NotifyCubit();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LangCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
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

      // Localization
      locale: langState.locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      // Theme
      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,

      // App Entry Point
      home: const NotificationInitializer(),
    );
  }
}
