import 'local_notification_services.dart';
import 'work_manager_service.dart';

enum NotificationType {
  prophetSalawat,
  azkarAlmasaa,
  azkarSabah,
  azkarAlnawm,
  nightPrayer,
}

class NotifyManager {
  final WorkManagerService _workManager = WorkManagerService();

  /// Enable Prophet Prayer notification
  Future<void> enableNotifications(
    NotificationType type, {
    int salawatIntervalIndex = 0,
        bool fridayBoost =false
  }) async {
    switch (type) {
      // 1- case NotificationType.prophetSalawat:
      case NotificationType.prophetSalawat:
        await _workManager.registerProphetPrayerTask();
        await LocalNotificationServices.scheduleProphetPrayer(
         fridayBoost: fridayBoost,
          intervalIndex: salawatIntervalIndex,
        );
        break;
      // 2-
      /// TODo
      //
      // 3 - case NotificationType.azkarAlmasaa:
      case NotificationType.azkarAlmasaa:
        await _workManager.registerAzkarAlmasaaTask();
        await LocalNotificationServices.dailyAzkarAlmasaa();
        break;

      // 4 - case NotificationType.azkarSabah:
      case NotificationType.azkarSabah:
        await _workManager.registerAzkarSabahTask();
        await LocalNotificationServices.dailyAzkarSabah();
        break;

      // 5 - case NotificationType.azkarSabah:
      case NotificationType.azkarAlnawm:
        await _workManager.registerAzkarAlnawmTask();
        await LocalNotificationServices.dailyAzkarAlnawm();
        break;

      case NotificationType.nightPrayer:
        // TODO: Handle this case.
        break;
    }
  }

  /// Disable Prophet Prayer notification
  Future<void> disableNotifications(NotificationType type) async {
    switch (type) {
      // 1- case NotificationType.prophetSalawat:
      case NotificationType.prophetSalawat:
        await _workManager.cancelProphetPrayerTask();
        await LocalNotificationServices.cancelNotification(1);
        break;
      // 2-
      /// TODo
      //
      // 3 - case NotificationType.azkarAlmasaa:
      case NotificationType.azkarAlmasaa:
        await _workManager.cancelAzkarAlmasaaTask();
        await LocalNotificationServices.cancelNotification(3);
        break;
      // 4 - case NotificationType.azkarAlmasaa:
      case NotificationType.azkarSabah:
        await _workManager.cancelAzkarSabahTask();
        await LocalNotificationServices.cancelNotification(4);
        break;
      // 5 - case NotificationType.azkarAlmasaa:
      case NotificationType.azkarAlnawm:
        await _workManager.cancelAzkarAlnawmTask();
        await LocalNotificationServices.cancelNotification(5);
        break;

      case NotificationType.nightPrayer:
        // TODO: Handle this case.
        break;
    }
  }
}
