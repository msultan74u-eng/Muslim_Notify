import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/services/adhan_services/prayer_service.dart';
import '../data/services/local_notification_services.dart';
import '../data/services/timezone_service.dart';

Future<void> showDebugInfo(BuildContext context) async {
  final buffer = StringBuffer();

  try {
    buffer.writeln('🧪 Testing FULL logic (with fallback)...');
    try {
      final currentTime = TimezoneService.currentTime();
      buffer.writeln('🕒 Current time: $currentTime');

      var prayerTimes = await PrayerService.getTodayPrayerTimes();
      buffer.writeln('✅ Today fajr: ${prayerTimes.fajr}');

      var notificationTime = PrayerService.getMorningAzkarTime(prayerTimes);
      buffer.writeln('📅 Today morning azkar time: $notificationTime');
      buffer.writeln(
        'Is after current: ${notificationTime.isAfter(currentTime)}',
      );

      if (!notificationTime.isAfter(currentTime)) {
        buffer.writeln('↪️ Rolling to tomorrow...');
        prayerTimes = await PrayerService.getPrayerTimes(
          currentTime.add(const Duration(days: 1)),
        );
        buffer.writeln('✅ Tomorrow fajr: ${prayerTimes.fajr}');

        notificationTime = PrayerService.getMorningAzkarTime(prayerTimes);
        buffer.writeln('📅 Tomorrow morning azkar time: $notificationTime');
      }

      final scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);
      buffer.writeln('📅 Final Scheduled TZDateTime: $scheduledDate');
      buffer.writeln(
        'Is future NOW: ${scheduledDate.isAfter(tz.TZDateTime.now(tz.local))}',
      );

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

      await LocalNotificationServices.flutterLocalNotificationsPlugin
          .zonedSchedule(
            id: 999,
            title: 'TEST',
            body: 'TEST',
            scheduledDate: scheduledDate,
            notificationDetails: notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );

      buffer.writeln('✅✅✅ zonedSchedule SUCCEEDED');
    } catch (e, s) {
      buffer.writeln('🔥🔥🔥 REAL EXCEPTION: $e');
      buffer.writeln('Type: ${e.runtimeType}');
      buffer.writeln('Stack: $s');
    }
  } catch (e, s) {
    buffer.writeln('\n🔥 OUTER ERROR: $e');
    buffer.writeln(s.toString());
  }

  if (context.mounted) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: SelectableText(buffer.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
