import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../data/enum/location_status.dart';
import '../data/services/adhan_services/location_service.dart';

class LocationServiceDialog {
  const LocationServiceDialog._();

  static Future<void> show(BuildContext context, LocationStatus status) async {
    final _DialogContent data = _resolveContent(context, status);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                data.content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await data.action();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: data.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    data.actionLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade500,
                ),
                child: Text(S.of(context).later),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _DialogContent _resolveContent(
    BuildContext context,
    LocationStatus status,
  ) {
    final s = S.of(context);
    switch (status) {
      case LocationStatus.serviceDisabled:
        return _DialogContent(
          icon: Icons.location_off_rounded,
          color: Colors.orange,
          title: s.locationServiceOff,
          content: s.locationServiceOffContent,
          actionLabel: s.enableLocationAction,
          action: LocationService.openLocationSettings,
        );

      case LocationStatus.permissionDeniedForever:
        return _DialogContent(
          icon: Icons.block_rounded,
          color: Colors.redAccent,
          title: s.permissionDeniedForeverTitle,
          content: s.permissionDeniedForeverContent,
          actionLabel: s.openAppSettings,
          action: LocationService.openAppSettings,
        );

      case LocationStatus.permissionDenied:
      default:
        return _DialogContent(
          icon: Icons.my_location_rounded,
          color: Colors.blueAccent,
          title: s.locationRequired,
          content: s.locationAccessRequiredContent,
          actionLabel: s.grantPermission,
          action: () async {
            await LocationService.requestPermission();
          },
        );
    }
  }
}

class _DialogContent {
  final IconData icon;
  final Color color;
  final String title;
  final String content;
  final String actionLabel;
  final Future<void> Function() action;

  const _DialogContent({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.action,
  });
}
