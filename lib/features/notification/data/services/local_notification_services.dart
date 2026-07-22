import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constant/notification_ids.dart';
import '../enum/prayer_type.dart';
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
  // static Future<void> init() async {
  //   await TimezoneService.initialize();
  //   InitializationSettings settings = InitializationSettings(
  //     android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  //
  //     iOS: DarwinInitializationSettings(),
  //   );
  //   await flutterLocalNotificationsPlugin.initialize(
  //     settings: settings,
  //     onDidReceiveNotificationResponse: onTap,
  //     onDidReceiveBackgroundNotificationResponse: onTap,
  //   );
  // }

  static Future<void> init() async {
    await TimezoneService.initialize();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );

    // إذا تم تشغيل التطبيق من خلال الإشعار
    final launchDetails = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;

      if (response != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          streamController.add(response);
        });
      }
    }
  }

  static Future<bool> requestPermissions() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return true;

    // 1. POST_NOTIFICATIONS (Android 13+)
    final notifGranted =
        await androidPlugin.requestNotificationsPermission() ?? false;
    log('📩 Notifications permission granted: $notifGranted');

    // 2. Exact Alarm permission (Android 12+)
    final canScheduleExact =
        await androidPlugin.canScheduleExactNotifications() ?? false;
    log('⏰ Can schedule exact alarms: $canScheduleExact');

    if (!canScheduleExact) {
      final exactGranted =
          await androidPlugin.requestExactAlarmsPermission() ?? false;
      log('⏰ Exact alarms permission granted: $exactGranted');
      return notifGranted && exactGranted;
    }

    return notifGranted && canScheduleExact;
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
    final prefs = await SharedPreferences.getInstance();

    final lastIntervalIndex = prefs.getInt(
      'last_prophet_prayer_interval_index',
    );
    final intervalChanged =
        lastIntervalIndex == null || lastIntervalIndex != intervalIndex;
    final pendingCount = await getPendingProphetPrayerNotificationsCount();
    const minimumPendingNotifications = 4;
    if (!intervalChanged && pendingCount >= minimumPendingNotifications) {
      log(
        '⏭️ Prophet Prayer notifications are still sufficient '
        '($pendingCount pending). '
        'Skipping new batch scheduling.',
      );
      return;
    }
    if (intervalChanged) {
      log(
        '🔄 Interval changed → cancelling old notifications and rescheduling',
      );
      await cancelAllProphetPrayerNotifications();
    }
    Duration interval;
    if (fridayBoost && _isFriday()) {
      log(
        '🌙 Friday Boost Enabled '
        '→ Scheduling every 15 minutes',
      );
      interval = const Duration(minutes: 15);
    } else {
      interval = _getProphetPrayerInterval(intervalIndex);
      log('🌙 Prophet Prayer interval: $interval');
    }
    await _scheduleProphetPrayerBatch(interval: interval);
    await prefs.setInt('last_prophet_prayer_interval_index', intervalIndex);
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
        // id: NotificationIds.prophetPrayer,
        id: 0,
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
        // id: NotificationIds.prophetPrayer,
        id: 0,
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
        'Scheduled_Night_prayer_channel_v5',
        'Scheduled Night Prayer Notifications',
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

  static Future<void> cancelPrayerReminders() async {
    for (final prayer in PrayerType.values) {
      await cancelNotification(NotificationIds.prayerReminderId(prayer));
    }
  }

  static Future<void> cancelPrayerAdhans() async {
    for (final prayer in PrayerType.values) {
      await cancelNotification(NotificationIds.prayerAdhanId(prayer));
    }
  }

  // Cancel all Prophet prayer notification
  static Future<void> cancelAllProphetPrayerNotifications() async {
    log('🗑️ Cancelling all Prophet Prayer notifications...');
    for (int i = 0; i < NotificationIds.prophetPrayerSlots; i++) {
      final notificationId = NotificationIds.prophetPrayerId(i);
      await cancelNotification(notificationId);
      log('❌ Cancelled Prophet Prayer notification: $notificationId');
    }
    log('✅ All Prophet Prayer notifications cancelled');
  }

  /// helpers
  static Future<bool> isNotificationPending(int id) async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    return pending.any((notification) => notification.id == id);
  }

  // get prophet prayer interval
  static Duration _getProphetPrayerInterval(int intervalIndex) {
    return switch (intervalIndex) {
      0 => const Duration(minutes: 15),
      1 => const Duration(minutes: 20),
      2 => const Duration(minutes: 30),
      3 => const Duration(hours: 1),
      4 => const Duration(hours: 2),
      5 => const Duration(hours: 3),
      _ => const Duration(minutes: 15),
    };
  }

  static tz.TZDateTime _getNextProphetPrayerTime({required Duration interval}) {
    final currentTime = TimezoneService.currentTime();
    final intervalMinutes = interval.inMinutes;
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final nextIntervalMinutes =
        ((currentMinutes ~/ intervalMinutes) + 1) * intervalMinutes;
    final nextDay = nextIntervalMinutes >= 24 * 60;

    if (nextDay) {
      return tz.TZDateTime(
        tz.local,
        currentTime.year,
        currentTime.month,
        currentTime.day,
        00,
        00,
      ).add(const Duration(days: 1));
    }
    final nextHour = nextIntervalMinutes ~/ 60;
    final nextMinute = nextIntervalMinutes % 60;
    return tz.TZDateTime(
      tz.local,
      currentTime.year,
      currentTime.month,
      currentTime.day,
      nextHour,
      nextMinute,
    );
  }

  ///    it`s for adhan prayer notification

  // 1- Public function Adhan Notification
  static Future<void> scheduleAdhanNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? soundName,
    String? payload,
  }) async {
    log('📢 scheduleAdhanNotification() CALLED');

    final selectedSound = soundName ?? 'the_best_human';

    final channelId = 'prayer_adhan_$selectedSound';

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    log('🆔 ID: $id');
    log('📝 Title: $title');
    log('📦 Payload: $payload');
    log('🔊 Sound: $selectedSound');
    log('📺 Channel: $channelId');
    log('🕒 Original Date: $scheduledDate');
    log('🕒 TZ Date: $tzDate');
    log('🌍 TZ Location: ${tz.local.name}');

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Prayer Adhan Notifications',
        channelDescription: 'Notifications for prayer times and Adhan',

        importance: Importance.max,
        priority: Priority.max,

        category: AndroidNotificationCategory.alarm,

        // إظهار كامل الشاشة
        fullScreenIntent: true,

        visibility: NotificationVisibility.public,

        // الصوت
        playSound: true,
        sound: RawResourceAndroidNotificationSound(selectedSound),

        autoCancel: false,
        ongoing: true,

        // مهم للأذان
        timeoutAfter: null,

        enableVibration: true,
      ),

      iOS: const DarwinNotificationDetails(),
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      log(
        '✅ Adhan notification scheduled successfully '
        'ID:$id',
      );
    } catch (e, stack) {
      log('❌ Failed scheduling Adhan: $e');
      log(stack.toString());
    }
  }

  // 2- schedulePrayerReminderNotification
  static Future<void> schedulePrayerReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? soundName,
    String? payload,
  }) async {
    final selectedSound = soundName ?? 'the_best_human';

    final channelId = 'prayer_reminder_$selectedSound';

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Prayer Reminder Notifications',
        channelDescription: 'Notifications before prayer times',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(selectedSound),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// new update salawat prophet

  static Future<void> _scheduleProphetPrayerNotification({
    required int notificationId,
    required tz.TZDateTime scheduledDate,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prophet_channel_v1',
        'Prophet Notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('the_best_human'),
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: '🌿 الصلاة على النبي ﷺ',
      body:
          'اللهم صلِّ وسلم وبارك على نبينا محمد، وأكثر من الصلاة عليه في يومك.',
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    log(
      '✅ Prophet Prayer scheduled '
      '→ ID: $notificationId '
      '→ Time: $scheduledDate',
    );
  }

  static Future<void> _scheduleProphetPrayerBatch({
    required Duration interval,
  }) async {
    log('📦 Scheduling Prophet Prayer batch...');
    log('⏱️ Interval: $interval');

    var scheduledDate = _getNextProphetPrayerTime(interval: interval);

    for (int i = 0; i < NotificationIds.prophetPrayerSlots; i++) {
      final notificationId = NotificationIds.prophetPrayerId(i);

      await _scheduleProphetPrayerNotification(
        notificationId: notificationId,
        scheduledDate: scheduledDate,
      );

      scheduledDate = scheduledDate.add(interval);
    }

    log('✅ Prophet Prayer batch scheduled successfully');
  }

  static Future<int> getPendingProphetPrayerNotificationsCount() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    final prophetPrayerNotifications = pending.where(
      (notification) =>
          notification.id >= NotificationIds.prophetPrayerBase &&
          notification.id <
              NotificationIds.prophetPrayerBase +
                  NotificationIds.prophetPrayerSlots,
    );

    return prophetPrayerNotifications.length;
  }
}
