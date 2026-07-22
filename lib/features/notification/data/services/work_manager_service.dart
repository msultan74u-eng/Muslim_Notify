import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'adhan_services/prayer_notification_service.dart';
import 'adhan_services/prayer_service.dart';
import 'local_notification_services.dart';

class WorkManagerService {
  ///   * init work manager service
  Future<void> init() async {
    await Workmanager().initialize(actionTask);
  }

  /// * register multi task

  // 1- register Prophet Prayer task
  Future<void> registerProphetPrayerTask() async {
    await Workmanager().registerPeriodicTask(
      'prophet_prayer_task',
      'prophet_prayer',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  // 2- register Azkar Sabah task
  Future<void> registerAzkarSabahTask() async {
    await Workmanager().registerPeriodicTask(
      'azkar_sabah_task',
      'azkar_sabah',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  // 3- register Azkar Almasaa task
  Future<void> registerAzkarAlmasaaTask() async {
    await Workmanager().registerPeriodicTask(
      'azkar_almasaa_task',
      'azkar_almasaa',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  // 4- register Azkar Alnawm task
  Future<void> registerAzkarAlnawmTask() async {
    await Workmanager().registerPeriodicTask(
      'azkar_alnawm_task',
      'azkar_alnawm',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  // 5- register Night Prayer task
  Future<void> registerNightPrayerTask() async {
    await Workmanager().registerPeriodicTask(
      'night_prayer_task',
      'night_prayer',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  // 6- register Prayer Reminder task
  Future<void> registerPrayerReminderTask() async {
    await Workmanager().registerPeriodicTask(
      'prayer_reminder_task',
      'prayer_reminder',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  // 7- register Prayer Adhan task
  Future<void> registerPrayerAdhanTask() async {
    await Workmanager().registerPeriodicTask(
      'prayer_adhan_task',
      'prayer_adhan',
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// * Cancel task
  // 1- cancel Prophet Prayer task
  Future<void> cancelProphetPrayerTask() async {
    await Workmanager().cancelByUniqueName('prophet_prayer_task');
  }

  // 2- cancel Azkar Almasaa task
  Future<void> cancelAzkarSabahTask() async {
    await Workmanager().cancelByUniqueName('azkar_sabah_task');
  }

  // 3- cancel Azkar Almasaa task
  Future<void> cancelAzkarAlmasaaTask() async {
    await Workmanager().cancelByUniqueName('azkar_almasaa_task');
  }

  // 4- cancel Azkar Almasaa task
  Future<void> cancelAzkarAlnawmTask() async {
    await Workmanager().cancelByUniqueName('azkar_alnawm_task');
  }

  // 5- cancel Night Prayer Task
  Future<void> cancelNightPrayerTask() async {
    await Workmanager().cancelByUniqueName('night_prayer_task');
  }

  // 6- cancel Prayer Reminder task
  Future<void> cancelPrayerReminderTask() async {
    await Workmanager().cancelByUniqueName('prayer_reminder_task');
  }

  // 7- cancel Prayer Adhan task
  Future<void> cancelPrayerAdhanTask() async {
    await Workmanager().cancelByUniqueName('prayer_adhan_task');
  }

  ///   cancel task by id
  Future<void> cancelTask(String id) async {
    await Workmanager().cancelByUniqueName(id);
  }
}

/// action task → that method will run in background
@pragma('vm:entry-point')
void actionTask() {
  Workmanager().executeTask((task, inputData) async {
    log("🚀 Background task started: $task");

    await LocalNotificationServices.init();

    log("🔥 Task Executed: $task");

    switch (task) {
      //
      case 'night_prayer':
        await LocalNotificationServices.dailyNightPrayer();
        break;

      case 'prophet_prayer':
        log("🔥 prophet_prayer task fired");

        final prefs = await SharedPreferences.getInstance();

        final isSalawatEnabled = prefs.getBool('salawat_enabled') ?? true;

        if (!isSalawatEnabled) {
          log("⏸️ Salawat notifications disabled by user. Skipping task.");
          break;
        }

        final intervalIndex = prefs.getInt('salawat_interval_index') ?? 0;

        final fridayBoost = prefs.getBool('friday_boost') ?? true;

        log("📌 intervalIndex = $intervalIndex");

        await LocalNotificationServices.scheduleProphetPrayer(
          intervalIndex: intervalIndex,
          fridayBoost: fridayBoost,
        );

        break;

      case 'azkar_almasaa':
        await LocalNotificationServices.dailyAzkarAlmasaa();
        break;

      case 'azkar_alnawm':
        await LocalNotificationServices.dailyAzkarAlnawm();
        break;

      case 'azkar_sabah':
        await LocalNotificationServices.dailyAzkarSabah();
        break;

      case 'prayer_reminder':
        log("🕌 Prayer Reminder task fired");

        final prefs = await SharedPreferences.getInstance();

        final isPrayerReminderEnabled =
            prefs.getBool('prayer_reminder_enabled') ?? true;

        if (!isPrayerReminderEnabled) {
          log(
            "⏸️ Prayer Reminder notifications disabled by user. "
            "Skipping task.",
          );
          break;
        }

        final prayerTimes = await PrayerService.getTodayPrayerTimes();

        await LocalNotificationServices.cancelPrayerReminders();

        await PrayerNotificationService.schedulePrayerReminders(prayerTimes);

        log("✅ Prayer Reminder notifications rescheduled");

        break;

      case 'prayer_adhan':
        log("🕌 Prayer Adhan task fired");

        final prefs = await SharedPreferences.getInstance();

        final isPrayerAdhanEnabled =
            prefs.getBool('prayer_adhan_enabled') ?? true;

        if (!isPrayerAdhanEnabled) {
          log(
            "⏸️ Prayer Adhan notifications disabled by user. "
            "Skipping task.",
          );
          break;
        }

        final fajrEnabled = prefs.getBool('fajr_adhan_enabled') ?? true;

        final dhuhrEnabled = prefs.getBool('dhuhr_adhan_enabled') ?? true;

        final asrEnabled = prefs.getBool('asr_adhan_enabled') ?? true;

        final maghribEnabled = prefs.getBool('maghrib_adhan_enabled') ?? true;

        final ishaEnabled = prefs.getBool('isha_adhan_enabled') ?? true;

        final prayerTimes = await PrayerService.getTodayPrayerTimes();

        await LocalNotificationServices.cancelPrayerAdhans();

        await PrayerNotificationService.schedulePrayerAdhans(
          prayerTimes,
          fajrEnabled: fajrEnabled,
          dhuhrEnabled: dhuhrEnabled,
          asrEnabled: asrEnabled,
          maghribEnabled: maghribEnabled,
          ishaEnabled: ishaEnabled,
        );

        log("✅ Prayer Adhan notifications rescheduled");

        break;

      default:
        log("❓ Unknown task: $task");
    }

    return true;
  });
}
