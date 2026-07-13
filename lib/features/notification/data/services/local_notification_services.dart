import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationServices {
  /// Creating a local notification plugin
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Create Stream Controller that listen to build context

  static final StreamController<NotificationResponse> streamController =
      StreamController<NotificationResponse>.broadcast();

  static void onTap(NotificationResponse notificationResponse) {
    streamController.add(notificationResponse);
  }

  /// for initialize in main.dart
  static Future<void> init() async {
    InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),

      iOS: DarwinInitializationSettings(),
    );
    flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );
  }

  /// Initialize time zone
  static Future<void> _initializeTimeZone() async {
    log("========== TimeZone Initialization ==========");

    tz.initializeTimeZones();

    log("Before → tz.local: ${tz.local}");
    log("Before → Time: ${tz.TZDateTime.now(tz.local)}");

    final timezone = await FlutterTimezone.getLocalTimezone();

    try {
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    }

    log("After → tz.local: ${tz.local}");
    log("After → Time: ${tz.TZDateTime.now(tz.local)}");

    log("============================================");
  }

  ///  1. Basic Notifications
  static void showNotification() async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_v1',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: DarwinNotificationDetails(),
    );
    flutterLocalNotificationsPlugin.show(
      id: 1,
      body: 'you`re Better than that....',
      title: 'Sultan',
      notificationDetails: notificationDetails,
      payload: 'payload Data',
    );
  }

  /// showRepeatedNotification
  static void showRepeatedNotification() async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel_v2',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id: 2,
      title: 'الصلاة على النبي ﷺ',
      body:
          '"اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ. اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ"',
      notificationDetails: notificationDetails,
      repeatInterval: RepeatInterval.everyMinute,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// showScheduledNotification
  static void showScheduledNotification() async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Scheduled_prayer_channel_v3',
        'Scheduled Prayer Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _initializeTimeZone();
    final scheduledDate = tz.TZDateTime(
      tz.local,
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      22,
      35,
    );
    log('Scheduled Date: $scheduledDate');
    log('Is Future: ${scheduledDate.isAfter(tz.TZDateTime.now(tz.local))}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 3,
      title: 'Scheduled Notification',
      body: 'Scheduled Notification Body',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    log('zonedSchedule() completed');

    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    log('Pending Notifications Count: ${pending.length}');
    for (final item in pending) {
      log('Pending -> id: ${item.id}, title: ${item.title}');
    }
  }

  ///  ☻☻☻☻☻☻☻☻     → for Muslim Notify      ☻☻☻☻☻☻☻☻
  ///                       Main Prophet Prayer

  // is Friday
  static bool _isFriday() {
    return tz.TZDateTime.now(tz.local).weekday == DateTime.friday;
  }

  static Future<void> scheduleProphetPrayer({
    required int intervalIndex,
    required bool fridayBoost,
  }) async {
    if (fridayBoost && _isFriday()) {
      log("🌙 Friday Boost Enabled → Scheduling every 15 minutes");
      await minuteProphetPrayer(minute: 15);
      return;
    } else {
      log("🌙 it isn`t Friday ");
      switch (intervalIndex) {
        case 0:
          await minuteProphetPrayer(minute: 15);
          break;

        case 1:
          await minuteProphetPrayer(minute: 20);
          break;

        case 2:
          await minuteProphetPrayer(minute: 30);
          break;

        case 3:
          await hourProphetPrayer(hour: 1);
          break;

        case 4:
          await hourProphetPrayer(hour: 2);
          break;

        case 5:
          await hourProphetPrayer(hour: 3);
          break;

        default:
          await minuteProphetPrayer(minute: 15);
      }
    }
  }

  /// 1 →  minute prophet prayer
  static Future<void> minuteProphetPrayer({int minute = 15}) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prophet_channel_v1',
        'Minute prophet Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final now = tz.TZDateTime.now(tz.local);

    int nextMinute = ((now.minute ~/ minute) + 1) * minute;
    int hour = now.hour;

    if (nextMinute >= 60) {
      nextMinute = 0;
      hour++;
    }

    final scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      nextMinute,
    );

    log("Current Time : $now");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 1,
        title: '🌿 الصلاة على النبي ﷺ',
        body:
            'اللهم صلِّ وسلم وبارك على نبينا محمد، وأكثر من الصلاة عليه في يومك.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("✅ Minute prophet prayer success");

      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      log("========== Pending Notifications ==========");

      for (final item in pending) {
        log("ID: ${item.id} | Title: ${item.title}");
      }

      log("==========================================");
    } catch (e, s) {
      log("❌ Minute prophet prayer error: $e");
      log("$s");
    }
  }

  /// 2 →  hour prophet prayer
  static Future<void> hourProphetPrayer({int hour = 1}) async {
    log('🔔 hourProphetPrayer() CALLED');
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prophet_channel_v1',
        'Hour prophet Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final currentTimeZone = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTimeZone.year,
      currentTimeZone.month,
      currentTimeZone.day,
      currentTimeZone.hour,
      00,
    );

    if (scheduledDate.isBefore(currentTimeZone)) {
      scheduledDate = scheduledDate.add(Duration(hours: hour));
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 1,
        title: '🌿 الصلاة على النبي ﷺ',
        body:
            'اللهم صلِّ وسلم وبارك على نبينا محمد، وأكثر من الصلاة عليه في يومك.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("✅ Hour Prophet Prayer success");
    } catch (e, s) {
      log("❌ daily Azkar Almasaa error: $e");
      log("$s");
    }
  }

  /// 3 →  daily azkar almasaa
  static Future<void> dailyAzkarAlmasaa() async {
    log('🔔 dailyAzkarAlmasaa() CALLED');
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Azkar_Almasaa_channel_v1',
        'Evening Azkar Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azkar_almasaa'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final currentTimeZone = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTimeZone.year,
      currentTimeZone.month,
      currentTimeZone.day,
      17,
      35,
    );

    if (scheduledDate.isBefore(currentTimeZone)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    log("Current Time : $currentTimeZone");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 3,
        title: '🌙 أذكار المساء',
        body:
            'اختم يومك بذكر الله، وداوم على أذكار المساء لتحفظ نفسك وتطمئن قلبك.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // matchDateTimeComponents: DateTimeComponents.time,
      );

      log("✅ daily Azkar Almasaa success");
      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      log("========== Pending Notifications ==========");

      for (final item in pending) {
        log("ID: ${item.id} | Title: ${item.title}");
      }

      log("==========================================");
    } catch (e, s) {
      log("❌ daily Azkar Almasaa error: $e");
      log("$s");
    }
  }

  /// 4 →  daily azkar sabah
  static Future<void> dailyAzkarSabah() async {
    log('🔔 dailyAzkarSabah CALLED');
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Azkar_Sabah_channel_v1',
        'Morning Azkar Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azkar_sabah'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final currentTimeZone = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTimeZone.year,
      currentTimeZone.month,
      currentTimeZone.day,
      21,
      25,
    );

    if (scheduledDate.isBefore(currentTimeZone)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    log("Current Time : $currentTimeZone");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 4,
        title: '🌞 أذكار الصباح',
        body: 'اذكر الله مع إشراقة هذا الصباح، واجعل لسانك رطبًا بذكره.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // matchDateTimeComponents: DateTimeComponents.time,
      );

      log("✅ daily Azkar Sabah success");
      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      log("========== Pending Notifications ==========");

      for (final item in pending) {
        log("ID: ${item.id} | Title: ${item.title}");
      }

      log("==========================================");
    } catch (e, s) {
      log("❌ daily Azkar Sabah error: $e");
      log("$s");
    }
  }

  /// 5 →  daily azkar Alnawm
  static Future<void> dailyAzkarAlnawm() async {
    log('🔔 dailyAzkarAlnawm CALLED');
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Azkar_Alnawm_channel_v1',
        'Night Azkar Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azkar_alnawm'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final currentTimeZone = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTimeZone.year,
      currentTimeZone.month,
      currentTimeZone.day,
      23,
      25,
    );

    if (scheduledDate.isBefore(currentTimeZone)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    log("Current Time : $currentTimeZone");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 5,
        title: '🌙 أذكار النوم',
        body: 'اذكر الله قبل نومك، واملأ قلبك سكينةً وطمأنينة.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // matchDateTimeComponents: DateTimeComponents.time,
      );

      log("✅ daily Azkar Alnawm success");
      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      log("========== Pending Notifications ==========");

      for (final item in pending) {
        log("ID: ${item.id} | Title: ${item.title}");
      }

      log("==========================================");
    } catch (e, s) {
      log("❌ daily Azkar Alnawm error: $e");
      log("$s");
    }
  }

  /// 6 →  daily Night Prayer
  static Future<void> dailyNightPrayer() async {
    log('🔔 dailyNightPrayer() CALLED');
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Scheduled_prayer_channel_v6',
        'Scheduled Prayer Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _initializeTimeZone();

    final currentTimeZone = tz.TZDateTime.now(tz.local);
    log('Current Time.year: ${currentTimeZone.year}');
    log('Current Time.month: ${currentTimeZone.month}');
    log('Current Time.day: ${currentTimeZone.day}');
    log('Current Time.hour: ${currentTimeZone.hour}');

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTimeZone.year,
      currentTimeZone.month,
      currentTimeZone.day,
      2,
      30,
    );
    log('Scheduled Date.year: ${scheduledDate.year}');
    log('Scheduled Date.month: ${scheduledDate.month}');
    log('Scheduled Date.day: ${scheduledDate.day}');
    log('Scheduled Date.hour: ${scheduledDate.hour}');

    if (scheduledDate.isBefore(currentTimeZone)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    log('After Scheduled Date.year: ${scheduledDate.year}');
    log('After Scheduled Date.month: ${scheduledDate.month}');
    log('After Scheduled Date.day: ${scheduledDate.day}');
    log('After Scheduled Date.hour: ${scheduledDate.hour}');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 6,
        title: '🌙 قيام الليل',
        body:
            'اغتنم بركة الثلث الأخير من الليل، وأحيِ قلبك بالصلاة والدعاء وتلاوة القرآن.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      log("✅ daily Night Prayer success");
    } catch (e, s) {
      log("❌ daily Night Prayer error: $e");
      log("$s");
    }
  }

  /// cancel notifications
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  static void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
