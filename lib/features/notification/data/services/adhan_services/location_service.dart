import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // SharedPreferences Keys
  static const String _latitudeKey = 'last_latitude';
  static const String _longitudeKey = 'last_longitude';
  static const String _locationNameKey = 'last_location_name';

  // instance for geocoding
  static final Geocoding _geocoding = Geocoding();

  // Location Service
  /// Check if device location service is enabled
  static Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Permission
  /// Check current location permission
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Settings
  /// Open device location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open application settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Get Current GPS Location
  /// Get current location from GPS
  ///
  /// This method requires:
  /// 1. Location service to be enabled
  /// 2. Location permission to be granted
  static Future<Position> getCurrentPosition() async {
    // Check if location service is enabled
    final serviceEnabled = await isLocationEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    // Request permission if needed
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }

    // Permission still denied
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied.');
    }

    // Permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. '
        'Please enable them from app settings.',
      );
    }

    // Get current GPS location
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // Save Last Valid Location
  /// Save the last valid GPS location
  ///
  /// This location will be used later if:
  /// - GPS is disabled
  /// - Location service is unavailable
  /// - WorkManager runs in the background
  /// Save the last valid location
  static Future<void> saveLastLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble(_latitudeKey, position.latitude);

    await prefs.setDouble(_longitudeKey, position.longitude);
  }

  // Get Last Saved Location
  /// Get the last saved location
  ///
  /// Returns null if no location has been saved yet.
  /// Get the last saved location
  static Future<Position?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();

    final latitude = prefs.getDouble(_latitudeKey);
    final longitude = prefs.getDouble(_longitudeKey);

    if (latitude == null || longitude == null) {
      return null;
    }

    return Position(
      longitude: longitude,
      latitude: latitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Check if a saved location exists
  static Future<bool> hasSavedLocation() async {
    final location = await getLastLocation();

    return location != null;
  }

  /// Get current location with fallback
  ///
  /// 1. Try to get the current GPS location.
  /// 2. Save the new location.
  /// 3. If GPS is unavailable, use the last saved location.
  static Future<Position> getLocationWithFallback() async {
    try {
      final currentPosition = await getCurrentPosition();

      await saveLastLocation(currentPosition);

      return currentPosition;
    } catch (e) {
      final lastLocation = await getLastLocation();

      if (lastLocation != null) {
        return lastLocation;
      }

      rethrow;
    }
  }

  /// Get location name from coordinates
  static Future<String?> getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      final placemark = placemarks.first;

      final parts = <String>[
        if (placemark.locality != null && placemark.locality!.isNotEmpty)
          placemark.locality!,
        if (placemark.country != null && placemark.country!.isNotEmpty)
          placemark.country!,
      ];

      return parts.isEmpty ? null : parts.join('، ');
    } catch (e) {
      return null;
    }
  }

  /// Get location name from cached coordinates
  static Future<String?> getLocationNameCached(
    double latitude,
    double longitude,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedLat = prefs.getDouble(_latitudeKey);
    final cachedLng = prefs.getDouble(_longitudeKey);
    final cachedName = prefs.getString(_locationNameKey);

    if (cachedLat == latitude && cachedLng == longitude && cachedName != null) {
      return cachedName;
    }

    final name = await getLocationName(latitude, longitude);

    if (name != null) {
      await prefs.setString(_locationNameKey, name);
    }

    return name;
  }
}
