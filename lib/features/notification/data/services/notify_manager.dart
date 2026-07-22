import '../constant/notification_ids.dart';
import '../enum/notification_type.dart';
import 'adhan_services/prayer_notification_service.dart';
import 'adhan_services/prayer_service.dart';
import 'local_notification_services.dart';
import 'work_manager_service.dart';

class NotifyManager {
  final WorkManagerService _workManager = WorkManagerService();

  Future<DateTime?> enableNotifications(
    NotificationType type, {
    int salawatIntervalIndex = 0,
    bool fridayBoost = false,
    bool fajrAdhanEnabled = true,
    bool dhuhrAdhanEnabled = true,
    bool asrAdhanEnabled = true,
    bool maghribAdhanEnabled = true,
    bool ishaAdhanEnabled = true,
  }) async {
    switch (type) {
      // 1- case prophetSalawat:
      case NotificationType.prophetSalawat:
        await LocalNotificationServices.cancelAllProphetPrayerNotifications();

        await _workManager.registerProphetPrayerTask();

        await LocalNotificationServices.scheduleProphetPrayer(
          fridayBoost: fridayBoost,
          intervalIndex: salawatIntervalIndex,
        );

        return null;

      // 2- case azkarSabah:
      case NotificationType.azkarSabah:
        await _workManager.registerAzkarSabahTask();

        return await LocalNotificationServices.dailyAzkarSabah();

      // 3- case azkarAlmasaa:
      case NotificationType.azkarAlmasaa:
        await _workManager.registerAzkarAlmasaaTask();

        return await LocalNotificationServices.dailyAzkarAlmasaa();

      // 4- case azkarAlnawm:
      case NotificationType.azkarAlnawm:
        await _workManager.registerAzkarAlnawmTask();

        return await LocalNotificationServices.dailyAzkarAlnawm();

      // 5- case nightPrayer:
      case NotificationType.nightPrayer:
        await _workManager.registerNightPrayerTask();

        return await LocalNotificationServices.dailyNightPrayer();

      // 6- case prayerReminder:
      case NotificationType.prayerReminder:
        final prayerTimes = await PrayerService.getTodayPrayerTimes();

        await PrayerNotificationService.schedulePrayerReminders(prayerTimes);

        await _workManager.registerPrayerReminderTask();

        return null;

      // 7- case prayerAdhan:
      case NotificationType.prayerAdhan:
        final prayerTimes = await PrayerService.getTodayPrayerTimes();

        await PrayerNotificationService.schedulePrayerAdhans(
          prayerTimes,
          fajrEnabled: fajrAdhanEnabled,
          dhuhrEnabled: dhuhrAdhanEnabled,
          asrEnabled: asrAdhanEnabled,
          maghribEnabled: maghribAdhanEnabled,
          ishaEnabled: ishaAdhanEnabled,
        );
        await _workManager.registerPrayerAdhanTask();

        return null;
    }
  }

  Future<void> disableNotifications(NotificationType type) async {
    switch (type) {
      // 1- case prophetSalawat:
      case NotificationType.prophetSalawat:
        await _workManager.cancelProphetPrayerTask();

        await LocalNotificationServices.cancelAllProphetPrayerNotifications();
        break;

      // 2- case azkarSabah:
      case NotificationType.azkarSabah:
        await _workManager.cancelAzkarSabahTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarSabah,
        );
        break;

      // 3- case azkarAlmasaa:
      case NotificationType.azkarAlmasaa:
        await _workManager.cancelAzkarAlmasaaTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarAlmasaa,
        );
        break;

      // 4- case azkarAlnawm:
      case NotificationType.azkarAlnawm:
        await _workManager.cancelAzkarAlnawmTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarAlnawm,
        );
        break;

      // 5- case nightPrayer:
      case NotificationType.nightPrayer:
        await _workManager.cancelNightPrayerTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.nightPrayer,
        );
        break;
      // 6- case prayerReminder:
      case NotificationType.prayerReminder:
        await _workManager.cancelPrayerReminderTask();

        await LocalNotificationServices.cancelPrayerReminders();
        break;

      // 7- case prayerAdhan:
      case NotificationType.prayerAdhan:
        await _workManager.cancelPrayerAdhanTask();

        await LocalNotificationServices.cancelPrayerAdhans();
        break;
    }
  }
}
