// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class TimezoneService {
//   /// 1- initial function
//   static Future<void> initialize() async {
//     tz.initializeTimeZones();
//     final timezone = await FlutterTimezone.getLocalTimezone();
//     try {
//       tz.setLocalLocation(tz.getLocation(timezone.identifier));
//     } catch (_) {
//       tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
//     }
//   }
//
//   /// 2- now function
//   static tz.TZDateTime currentTime() {
//     return tz.TZDateTime.now(tz.local);
//   }
//
//   /// 3- local function
//   static tz.Location get local => tz.local;
// }

import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezoneService {
  static bool _isInitialized = false;

  /// Initialize timezone only once
  static Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    final timezone = await FlutterTimezone.getLocalTimezone();

    try {
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    }

    _isInitialized = true;
  }

  /// Get current time
  static tz.TZDateTime currentTime() {
    return tz.TZDateTime.now(tz.local);
  }

  /// Get current location
  static tz.Location get local => tz.local;
}
