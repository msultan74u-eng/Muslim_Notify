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
import 'features/notification/data/services/local_notification_services.dart';
import 'features/notification/data/services/work_manager_service.dart';
import 'features/notification/logic/cubits/notify_cubit.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///  initialization of storage for using  Hydrated Bloc
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationSupportDirectory()).path,
          ),
  );
  await Future.wait([
    LocalNotificationServices.init(),
    WorkManagerService().init(),
  ]);
  await LocalNotificationServices.dailyNightPrayer();

  /// initialize notifications
  final notifyCubit = NotifyCubit();
  await notifyCubit.initializeNotifications();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LangCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
        // BlocProvider(create: (context) => NotifyCubit()),
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

      /// Localization for flutter intl
      locale: langState.locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      theme: getLightTheme(),
      darkTheme: getDarkTheme(),
      themeMode: themeMode,

      home: const BottomNavPage(),
    );
  }
}
