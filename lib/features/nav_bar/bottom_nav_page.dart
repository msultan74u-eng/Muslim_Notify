import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/navigation/app_navigator.dart';
import '../home/views/home_page.dart';
import 'floating_nav_bar.dart';
import '../notification/data/services/local_notification_services.dart';
import '../notification/logic/prayer_times_cubit/prayer_times_cubit.dart';
import '../notification/views/adhan_page.dart';
import '../notification/views/notification_page.dart';
import 'nav_bar_cubit/nav_bar_cubit.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NotificationPage(),
    const HomePage(),
    const AdhanPage(prayerType: 'العشاء'),
    const AdhanPage(prayerType: 'العشاء'),
  ];

  final List<NavBarItemData> _navItems = const [
    NavBarItemData(
      icon: Icons.notifications_outlined,
      selectedIcon: Icons.notifications,
      label: 'Notify',
    ),
    NavBarItemData(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavBarItemData(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Learn',
    ),
    NavBarItemData(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Learn',
    ),
  ];

  /// Initial state
  @override
  void initState() {
    super.initState();

    listenToNotificationStream();
  }

  /// Send context to WorkManager → Notification

  void listenToNotificationStream() {
    LocalNotificationServices.streamController.stream.listen((
      notificationResponse,
    ) {
      log('🔥 Notification Listener Fired');
      log('Payload = ${notificationResponse.payload}');

      final payload = notificationResponse.payload ?? '';

      if (payload.startsWith('prayer_adhan')) {
        final prayerType = payload.split('|')[1];

        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => AdhanPage(prayerType: prayerType)),
        );

        return;
      }
      setState(() {
        _currentIndex = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerTimesCubit>(
          create: (_) => PrayerTimesCubit()..getTodayPrayerTimes(),
        ),
        BlocProvider<NavBarCubit>(create: (_) => NavBarCubit()),
      ],

      child: Scaffold(
        extendBody: true,

        body: Builder(
          builder: (context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: () {
              context.read<NavBarCubit>().toggle();
            },
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 200) {
                context.read<NavBarCubit>().hide();
              }
              if (velocity < -200) {
                context.read<NavBarCubit>().show();
              }
            },
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ),

        bottomNavigationBar: BlocBuilder<NavBarCubit, bool>(
          builder: (context, isVisible) {
            return IgnorePointer(
              ignoring: !isVisible,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                offset: isVisible ? const Offset(0, 0) : const Offset(0, 1.2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isVisible ? 1 : 0,
                  child: FloatingNavBar(
                    currentIndex: _currentIndex,
                    items: _navItems,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
