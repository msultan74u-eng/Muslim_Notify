class PrayerTimesModel {
  final DateTime date;

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  final double latitude;
  final double longitude;

  final String? locationName;

  const PrayerTimesModel({
    required this.date,

    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,

    required this.latitude,
    required this.longitude,

    this.locationName,
  });

  PrayerTimesModel copyWith({
    DateTime? date,

    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,

    double? latitude,
    double? longitude,
    String? locationName,
  }) {
    return PrayerTimesModel(
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'fajr': fajr.toIso8601String(),
      'sunrise': sunrise.toIso8601String(),
      'dhuhr': dhuhr.toIso8601String(),
      'asr': asr.toIso8601String(),
      'maghrib': maghrib.toIso8601String(),
      'isha': isha.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
    };
  }

  factory PrayerTimesModel.fromMap(Map<String, dynamic> map) {
    return PrayerTimesModel(
      date: DateTime.parse(map['date']),
      fajr: DateTime.parse(map['fajr']),
      sunrise: DateTime.parse(map['sunrise']),
      dhuhr: DateTime.parse(map['dhuhr']),
      asr: DateTime.parse(map['asr']),
      maghrib: DateTime.parse(map['maghrib']),
      isha: DateTime.parse(map['isha']),
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      locationName: map['locationName'],
    );
  }
}
