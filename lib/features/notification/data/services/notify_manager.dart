import '../constant/notification_ids.dart';
import '../enum/notification_type.dart';
import 'local_notification_services.dart';
import 'work_manager_service.dart';

class NotifyManager {
  final WorkManagerService _workManager = WorkManagerService();

  Future<DateTime?> enableNotifications(
    NotificationType type, {
    int salawatIntervalIndex = 0,
    bool fridayBoost = false,
  }) async {
    switch (type) {
      case NotificationType.prophetSalawat:
        await _workManager.registerProphetPrayerTask();

        await LocalNotificationServices.scheduleProphetPrayer(
          fridayBoost: fridayBoost,
          intervalIndex: salawatIntervalIndex,
        );

        return null;

      case NotificationType.azkarSabah:
        await _workManager.registerAzkarSabahTask();

        return await LocalNotificationServices.dailyAzkarSabah();

      case NotificationType.azkarAlmasaa:
        await _workManager.registerAzkarAlmasaaTask();

        return await LocalNotificationServices.dailyAzkarAlmasaa();

      case NotificationType.azkarAlnawm:
        await _workManager.registerAzkarAlnawmTask();

        return await LocalNotificationServices.dailyAzkarAlnawm();

      case NotificationType.nightPrayer:
        await _workManager.registerNightPrayerTask();

        return await LocalNotificationServices.dailyNightPrayer();
    }
  }

  Future<void> disableNotifications(NotificationType type) async {
    switch (type) {
      case NotificationType.prophetSalawat:
        await _workManager.cancelProphetPrayerTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.prophetPrayer,
        );
        break;

      case NotificationType.azkarSabah:
        await _workManager.cancelAzkarSabahTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarSabah,
        );
        break;

      case NotificationType.azkarAlmasaa:
        await _workManager.cancelAzkarAlmasaaTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarAlmasaa,
        );
        break;

      case NotificationType.azkarAlnawm:
        await _workManager.cancelAzkarAlnawmTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.azkarAlnawm,
        );
        break;

      case NotificationType.nightPrayer:
        await _workManager.cancelNightPrayerTask();

        await LocalNotificationServices.cancelNotification(
          NotificationIds.nightPrayer,
        );
        break;
    }
  }
}
