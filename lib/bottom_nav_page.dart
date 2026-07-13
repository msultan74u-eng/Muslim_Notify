import 'dart:developer';

import 'package:flutter/material.dart';

import 'features/home/views/home_page.dart';
import 'features/notification/data/services/local_notification_services.dart';
import 'features/notification/views/notification_page.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    NotificationPage(),
    HomePage(),
    LearnNotification(),
  ];

  /// initial state
  @override
  void initState() {
    super.initState();
    listenToNotificationStream();
  }

  /// send context to work Manager → Notification
  void listenToNotificationStream() {
    LocalNotificationServices.streamController.stream.listen((
      notificationResponse,
    ) {
      log(' ID Notify → ${notificationResponse.id!.toString()}');
      log(' Payload → ${notificationResponse.payload}');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => NotificationPage()),
      // );
      setState(() {
        _currentIndex = 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
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
        title: Text(
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
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications),
                        color: Colors.blue,
                        iconSize: 32,
                        // splashRadius: 50,
                      ),
                      TextButton(
                        onPressed: () {
                          LocalNotificationServices.showNotification();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.amberAccent,
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        child: Text(
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
                  icon: Icon(Icons.cancel),
                  color: Colors.red,
                  iconSize: 26,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications),
                    color: Colors.blue,
                    iconSize: 32,
                    // splashRadius: 50,
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications),
                    color: Colors.blue,
                    iconSize: 32,
                    // splashRadius: 50,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                LocalNotificationServices.cancelAllNotifications();
              },
              child: Text('Cancel All'),
            ),
          ],
        ),
      ),
    );
  }
}
