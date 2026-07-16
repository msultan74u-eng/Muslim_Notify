import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constant/notification_ids.dart';
import 'adhan_services/prayer_service.dart';
import 'timezone_service.dart';

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
    await TimezoneService.initialize();
    InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),

      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );
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
    // await _initializeTimeZone();
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

  static bool _isFriday() {
    final now = TimezoneService.currentTime();
    return now.weekday == DateTime.friday;
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

  /// id : 1 →  minute prophet prayer
  static Future<void> minuteProphetPrayer({int minute = 15}) async {
    log('🔔 minuteProphetPrayer() CALLED');
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

    final currentTime = TimezoneService.currentTime();
    int nextMinute = ((currentTime.minute ~/ minute) + 1) * minute;
    int hour = currentTime.hour;

    if (nextMinute >= 60) {
      nextMinute = 0;
      hour++;
    }

    final scheduledDate = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      hour,
      nextMinute,
    );

    log("Current Time : $currentTime");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.prophetPrayer,
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

  /// id : 1 →  hour prophet prayer
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

    final currentTime = TimezoneService.currentTime();

    var scheduledDate = tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      currentTime.hour,
      00,
    );

    if (scheduledDate.isBefore(currentTime)) {
      scheduledDate = scheduledDate.add(Duration(hours: hour));
    }
    log("Current Time : $currentTime");
    log("Scheduled Time : $scheduledDate");
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.prophetPrayer,
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

  /// id : 2 →  daily azkar sabah
  static Future<DateTime?> dailyAzkarSabah() async {
    log('🔔 dailyAzkarSabah CALLED');

    final notificationDetails = NotificationDetails(
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

    final currentTime = TimezoneService.currentTime();

    var prayerTimes = await PrayerService.getTodayPrayerTimes();

    var notificationTime = PrayerService.getMorningAzkarTime(prayerTimes);

    if (!notificationTime.isAfter(currentTime)) {
      prayerTimes = await PrayerService.getPrayerTimes(
        currentTime.add(const Duration(days: 1)),
      );

      notificationTime = PrayerService.getMorningAzkarTime(prayerTimes);
    }

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    log("Current Time: $currentTime");
    log("Scheduled Time: $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.azkarSabah,
        title: '🌞 أذكار الصباح',
        body: 'اذكر الله مع إشراقة هذا الصباح، واجعل لسانك رطبًا بذكره.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("✅ daily Azkar Sabah success");

      return scheduledDate;
    } catch (e, s) {
      log("❌ daily Azkar Sabah error: $e");
      log("$s");

      return null;
    }
  }

  /// id : 3 →  daily azkar almasaa
  static Future<DateTime?> dailyAzkarAlmasaa() async {
    log('🔔 dailyAzkarAlmasaa() CALLED');

    final notificationDetails = NotificationDetails(
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

    final currentTime = TimezoneService.currentTime();

    var prayerTimes = await PrayerService.getTodayPrayerTimes();

    var notificationTime = PrayerService.getEveningAzkarTime(prayerTimes);

    if (!notificationTime.isAfter(currentTime)) {
      prayerTimes = await PrayerService.getPrayerTimes(
        currentTime.add(const Duration(days: 1)),
      );

      notificationTime = PrayerService.getEveningAzkarTime(prayerTimes);
    }

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    log("Current Time : $currentTime");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.azkarAlmasaa,
        title: '🌙 أذكار المساء',
        body:
            'اختم يومك بذكر الله، وداوم على أذكار المساء لتحفظ نفسك وتطمئن قلبك.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("✅ daily Azkar Almasaa success");
      return scheduledDate;
    } catch (e, s) {
      log("❌ daily Azkar Almasaa error: $e");
      log("$s");
      return null;
    }
  }

  /// id : 4 →  daily azkar Alnawm
  static Future<DateTime?> dailyAzkarAlnawm() async {
    log('🔔 dailyAzkarAlnawm CALLED');

    final notificationDetails = NotificationDetails(
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

    final currentTime = TimezoneService.currentTime();

    var prayerTimes = await PrayerService.getTodayPrayerTimes();

    var notificationTime = PrayerService.getSleepingAzkarTime(prayerTimes);

    // إذا مر وقت أذكار النوم اليوم، نحسب وقت الغد
    if (!notificationTime.isAfter(currentTime)) {
      prayerTimes = await PrayerService.getPrayerTimes(
        currentTime.add(const Duration(days: 1)),
      );

      notificationTime = PrayerService.getSleepingAzkarTime(prayerTimes);
    }

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    log("Current Time : $currentTime");
    log("Scheduled Time : $scheduledDate");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.azkarAlnawm,
        title: '🌙 أذكار النوم',
        body: 'اذكر الله قبل نومك، واملأ قلبك سكينةً وطمأنينة.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log("✅ daily Azkar Alnawm success");

      final pending = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      log("========== Pending Notifications ==========");

      for (final item in pending) {
        log("ID: ${item.id} | Title: ${item.title}");
      }

      log("==========================================");
      return scheduledDate;
    } catch (e, s) {
      log("❌ daily Azkar Alnawm error: $e");
      log("$s");
      return null;
    }
  }

  /// id : 5 →  daily Night Prayer
  static Future<DateTime?> dailyNightPrayer() async {
    log('🔔 dailyNightPrayer() CALLED');

    final prefs = await SharedPreferences.getInstance();

    // Check if an existing Night Prayer notification is already scheduled
    final isPending = await isNotificationPending(NotificationIds.nightPrayer);

    // Get the previously saved scheduled time
    final savedTime = prefs.getString('night_prayer_scheduled_time');

    if (savedTime != null) {
      log('🌙 Saved Night Prayer Time: $savedTime');
    }

    if (isPending) {
      log(
        '⏭️ Night Prayer notification is already pending. '
        'No new notification will be scheduled.',
      );

      // Return the previously scheduled time
      if (savedTime != null) {
        return DateTime.tryParse(savedTime);
      }

      return null;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'Scheduled_prayer_channel_v5',
        'Scheduled Prayer Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final currentTime = TimezoneService.currentTime();

    var prayerTimes = await PrayerService.getTodayPrayerTimes();

    var notificationTime = await PrayerService.getNightPrayerNotificationTime(
      prayerTimes,
    );

    if (!notificationTime.isAfter(currentTime)) {
      prayerTimes = await PrayerService.getPrayerTimes(
        currentTime.add(const Duration(days: 1)),
      );

      notificationTime = await PrayerService.getNightPrayerNotificationTime(
        prayerTimes,
      );
    }

    final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    log('🕒 Current Time: $currentTime');
    log('🌙 Scheduled Time: $scheduledDate');

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: NotificationIds.nightPrayer,
        title: '🌙 قيام الليل',
        body:
            'اغتنم بركة الثلث الأخير من الليل، وأحيِ قلبك بالصلاة والدعاء وتلاوة القرآن.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      // Save the scheduled notification time
      await prefs.setString(
        'night_prayer_scheduled_time',
        scheduledDate.toIso8601String(),
      );

      log('✅ Night Prayer notification scheduled successfully.');

      return scheduledDate;
    } catch (e, s) {
      log('❌ Night Prayer notification error: $e');
      log('$s');

      return null;
    }
  }

  /// cancel notifications
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  static void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// helpers
  static Future<bool> isNotificationPending(int id) async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    return pending.any((notification) => notification.id == id);
  }
}
