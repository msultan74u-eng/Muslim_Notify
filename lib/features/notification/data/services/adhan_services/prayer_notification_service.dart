import 'dart:developer';

import 'package:muslim_notify/features/notification/data/constant/notification_ids.dart';
import 'package:muslim_notify/features/notification/data/enum/prayer_type.dart';
import 'package:muslim_notify/features/notification/data/models/prayer_times_model.dart';
import 'package:muslim_notify/features/notification/data/services/adhan_services/prayer_service.dart';
import 'package:muslim_notify/features/notification/data/services/local_notification_services.dart';
import 'package:muslim_notify/features/notification/data/services/timezone_service.dart';

class PrayerNotificationService {
  /// 1- Schedule Prayer Reminder Notifications
  static Future<void> schedulePrayerReminders(
    PrayerTimesModel prayerTimes,
  ) async {
    final currentTime = TimezoneService.currentTime();

    final prayers = PrayerService.getAllPrayers(prayerTimes);

    //  (lazy load) get tomorrow's prayer times
    PrayerTimesModel? tomorrowPrayerTimes;

    for (final prayer in prayers) {
      final prayerType = prayer.$1;
      var prayerTime = prayer.$2;

      // if reminder time is in the past, schedule for tomorrow
      if (!prayerTime.isAfter(currentTime)) {
        tomorrowPrayerTimes ??= await PrayerService.getPrayerTimes(
          currentTime.add(const Duration(days: 1)),
        );
        prayerTime = PrayerService.getPrayerTime(
          tomorrowPrayerTimes,
          prayerType,
        );
      }

      final reminderTime = prayerTime.subtract(const Duration(minutes: 10));

      // if reminder time is in the past, skip it
      if (!reminderTime.isAfter(currentTime)) {
        continue;
      }

      await LocalNotificationServices.schedulePrayerReminderNotification(
        id: NotificationIds.prayerReminderId(prayerType),
        title: _getReminderTitle(prayerType),
        body: _getReminderBody(prayerType),
        scheduledDate: reminderTime,
        soundName: 'the_best_human',
        payload: 'prayer_reminder|${prayerType.name}',
      );
    }
  }

  /// 2- Schedule Prayer Adhan Notifications
  static Future<void> schedulePrayerAdhans(
    PrayerTimesModel prayerTimes, {
    required bool fajrEnabled,
    required bool dhuhrEnabled,
    required bool asrEnabled,
    required bool maghribEnabled,
    required bool ishaEnabled,
  }) async {
    log('🕌 schedulePrayerAdhans() START');

    final currentTime = TimezoneService.currentTime();

    log('🕒 Current Time: $currentTime');

    final prayers = PrayerService.getAllPrayers(prayerTimes);

    log('📋 Total Prayers: ${prayers.length}');

    PrayerTimesModel? tomorrowPrayerTimes;

    for (final prayer in prayers) {
      final prayerType = prayer.$1;
      var prayerTime = prayer.$2;

      log('--------------------------------');
      log('➡️ Prayer: ${prayerType.name}');
      log('🕒 Prayer Time: $prayerTime');

      final isEnabled = switch (prayerType) {
        PrayerType.fajr => fajrEnabled,
        PrayerType.dhuhr => dhuhrEnabled,
        PrayerType.asr => asrEnabled,
        PrayerType.maghrib => maghribEnabled,
        PrayerType.isha => ishaEnabled,
      };

      log('🔔 Enabled: $isEnabled');

      if (!isEnabled) {
        log('⏭️ Skip ${prayerType.name}');
        continue;
      }

      // إذا كان موعد الصلاة انتهى نأخذ موعد الغد
      if (!prayerTime.isAfter(currentTime)) {
        log(
          '⚠️ ${prayerType.name} time passed '
          '(Current: $currentTime)',
        );

        tomorrowPrayerTimes ??= await PrayerService.getPrayerTimes(
          currentTime.add(const Duration(days: 1)),
        );

        prayerTime = PrayerService.getPrayerTime(
          tomorrowPrayerTimes!,
          prayerType,
        );

        log('📅 Tomorrow ${prayerType.name}: $prayerTime');
      }

      final notificationId = NotificationIds.prayerAdhanId(prayerType);

      log('📢 Scheduling Adhan');
      log('🆔 Notification ID: $notificationId');
      log('⏰ Fire Time: $prayerTime');

      await LocalNotificationServices.scheduleAdhanNotification(
        id: notificationId,
        title: _getAdhanTitle(prayerType),
        body: _getAdhanBody(prayerType),
        scheduledDate: prayerTime,
        soundName: 'the_best_human',
        payload: 'prayer_adhan|${prayerType.name}',
      );

      log('✅ ${prayerType.name} Adhan scheduled successfully');
    }

    log('🎉 schedulePrayerAdhans() FINISHED');
  }

  static String _getReminderTitle(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => '🕌 اقترب موعد صلاة الفجر',
      PrayerType.dhuhr => '🕌 اقترب موعد صلاة الظهر',
      PrayerType.asr => '🕌 اقترب موعد صلاة العصر',
      PrayerType.maghrib => '🕌 اقترب موعد صلاة المغرب',
      PrayerType.isha => '🕌 اقترب موعد صلاة العشاء',
    };
  }

  static String _getReminderBody(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => 'تبقى 10 دقائق على أذان الفجر',
      PrayerType.dhuhr => 'تبقى 10 دقائق على أذان الظهر',
      PrayerType.asr => 'تبقى 10 دقائق على أذان العصر',
      PrayerType.maghrib => 'تبقى 10 دقائق على أذان المغرب',
      PrayerType.isha => 'تبقى 10 دقائق على أذان العشاء',
    };
  }

  static String _getAdhanTitle(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => '🕌 حان الآن موعد صلاة الفجر',
      PrayerType.dhuhr => '🕌 حان الآن موعد صلاة الظهر',
      PrayerType.asr => '🕌 حان الآن موعد صلاة العصر',
      PrayerType.maghrib => '🕌 حان الآن موعد صلاة المغرب',
      PrayerType.isha => '🕌 حان الآن موعد صلاة العشاء',
    };
  }

  static String _getAdhanBody(PrayerType prayer) {
    return switch (prayer) {
      PrayerType.fajr => 'الله أكبر، الله أكبر',
      PrayerType.dhuhr => 'حان الآن وقت صلاة الظهر',
      PrayerType.asr => 'حان الآن وقت صلاة العصر',
      PrayerType.maghrib => 'حان الآن وقت صلاة المغرب',
      PrayerType.isha => 'حان الآن وقت صلاة العشاء',
    };
  }
}
