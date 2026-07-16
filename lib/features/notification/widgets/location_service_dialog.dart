import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<bool> showLocationServiceDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('تفعيل خدمة الموقع'),
        content: const Text(
          'نحتاج إلى تفعيل خدمة الموقع لحساب مواقيت الصلاة بدقة '
          'وجدولة الإشعارات الخاصة بالأذكار وقيام الليل.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('لاحقًا'),
          ),
          ElevatedButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();

              if (context.mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
