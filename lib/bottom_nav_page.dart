import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/navigation/app_navigator.dart';
import 'features/home/views/home_page.dart';
import 'features/notification/data/services/local_notification_services.dart';
import 'features/notification/logic/prayer_times_cubit/prayer_times_cubit.dart';
import 'features/notification/views/adhan_page.dart';
import 'features/notification/views/notification_page.dart';

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
    const LearnNotification(),
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
        // BlocProvider<NotifyCubit>(
        //   create: (_) => NotifyCubit()..initializeNotifications(),
        // ),
        BlocProvider<PrayerTimesCubit>(
          create: (_) => PrayerTimesCubit()..getTodayPrayerTimes(),
        ),
      ],

      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),

        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,

          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.notifications),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),

            NavigationDestination(
              icon: Icon(Icons.home),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),

            NavigationDestination(
              icon: Icon(Icons.notifications),
              selectedIcon: Icon(Icons.notifications),
              label: 'Learn',
            ),
          ],
        ),
      ),
    );
  }
}

class LearnNotification extends StatefulWidget {
  const LearnNotification({super.key});

  @override
  State<LearnNotification> createState() => _LearnNotificationState();
}

class _LearnNotificationState extends State<LearnNotification> {
  bool isNotificationEnabled = false;
  bool isScheduledNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,

        title: const Text(
          'Flutter Notifications',
          style: TextStyle(color: Colors.white),
        ),

        centerTitle: true,

        leading: const Icon(Icons.notifications, color: Colors.white),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.blue,
                        size: 32,
                      ),

                      TextButton(
                        onPressed: () {
                          LocalNotificationServices.showNotification();
                        },

                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.amberAccent,
                          ),
                        ),

                        child: const Text(
                          'Local Notification',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    LocalNotificationServices.cancelNotification(0);
                  },

                  icon: const Icon(Icons.cancel),

                  color: Colors.red,

                  iconSize: 26,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                const Expanded(
                  flex: 1,

                  child: Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),

                Expanded(
                  flex: 3,

                  child: CheckboxListTile(
                    title: const Text("تفعيل الصلاة على النبي ﷺ"),

                    value: isNotificationEnabled,

                    onChanged: (value) {
                      setState(() {
                        isNotificationEnabled = value!;
                      });

                      if (isNotificationEnabled) {
                        LocalNotificationServices.showRepeatedNotification();
                      } else {
                        LocalNotificationServices.cancelNotification(2);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
                const Expanded(
                  flex: 1,

                  child: Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),

                Expanded(
                  flex: 3,

                  child: CheckboxListTile(
                    title: const Text("Scheduled Notification"),

                    value: isScheduledNotificationEnabled,

                    onChanged: (value) {
                      setState(() {
                        isScheduledNotificationEnabled = value!;
                      });

                      if (isScheduledNotificationEnabled) {
                        LocalNotificationServices.showScheduledNotification();
                      } else {
                        LocalNotificationServices.cancelNotification(3);
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                LocalNotificationServices.cancelAllNotifications();
              },

              child: const Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }
}
