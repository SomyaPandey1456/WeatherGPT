import 'location.dart';

class CurrentWeather {
  final LocationModel location;
  final double temperatureC;
  final String condition;
  final String iconCode;
  final double feelsLikeC;
  final int humidityPercent;
  final double windSpeedKmH;
  final String windDirection;
  final double visibilityKm;
  final int pressureHpa;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final int airQualityIndex;
  final DateTime lastUpdated;

  const CurrentWeather({
    required this.location,
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
    required this.feelsLikeC,
    required this.humidityPercent,
    required this.windSpeedKmH,
    required this.windDirection,
    required this.visibilityKm,
    required this.pressureHpa,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.airQualityIndex,
    required this.lastUpdated,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      location: LocationModel.fromJson(json['location'] ?? {}),
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 28.0,
      condition: json['condition'] ?? 'Partly Cloudy',
      iconCode: json['icon_code'] ?? 'partly_cloudy',
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble() ?? 30.0,
      humidityPercent: json['humidity_percent'] ?? 62,
      windSpeedKmH: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      windDirection: json['wind_direction'] ?? 'SW',
      visibilityKm: (json['visibility_km'] as num?)?.toDouble() ?? 8.0,
      pressureHpa: json['pressure_hpa'] ?? 1006,
      uvIndex: json['uv_index'] ?? 5,
      sunrise: json['sunrise'] ?? '5:37 AM',
      sunset: json['sunset'] ?? '6:58 PM',
      airQualityIndex: json['aqi'] ?? 84,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'temperature_c': temperatureC,
      'condition': condition,
      'icon_code': iconCode,
      'feels_like_c': feelsLikeC,
      'humidity_percent': humidityPercent,
      'wind_speed_kmh': windSpeedKmH,
      'wind_direction': windDirection,
      'visibility_km': visibilityKm,
      'pressure_hpa': pressureHpa,
      'uv_index': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
      'aqi': airQualityIndex,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
