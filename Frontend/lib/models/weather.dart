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
    final current = (json['current'] is Map) ? json['current'] as Map<String, dynamic> : json;
    final locMap = (json['location'] is Map) ? json['location'] as Map<String, dynamic> : {};

    final temp = (current['temperature'] as num?)?.toDouble() ??
        (current['temperature_2m'] as num?)?.toDouble() ??
        (json['temperature_c'] as num?)?.toDouble() ??
        28.0;

    final feels = (current['apparent_temperature'] as num?)?.toDouble() ??
        (json['feels_like_c'] as num?)?.toDouble() ??
        temp;

    final hum = (current['humidity'] as num?)?.toInt() ??
        (current['relative_humidity_2m'] as num?)?.toInt() ??
        (json['humidity_percent'] as num?)?.toInt() ??
        60;

    final wind = (current['wind_speed'] as num?)?.toDouble() ??
        (current['wind_speed_10m'] as num?)?.toDouble() ??
        (json['wind_speed_kmh'] as num?)?.toDouble() ??
        12.0;

    final weatherCode = (current['weather_code'] as num?)?.toInt() ?? 0;
    String condStr = json['condition']?.toString() ?? 'Partly Cloudy';
    if (json['condition'] == null) {
      if ([1, 2, 3].contains(weatherCode)) {
        condStr = 'Partly Cloudy';
      } else if ([45, 48].contains(weatherCode)) {
        condStr = 'Foggy';
      } else if ([51, 53, 55, 61, 63, 65, 80, 81].contains(weatherCode)) {
        condStr = 'Rain Showers';
      } else if ([95, 96, 99].contains(weatherCode)) {
        condStr = 'Thunderstorm';
      } else if (weatherCode == 0) {
        condStr = 'Clear Sunny';
      }
    }

    return CurrentWeather(
      location: LocationModel.fromJson(Map<String, dynamic>.from(locMap)),

      temperatureC: temp,
      condition: condStr,
      iconCode: json['icon_code'] ?? 'partly_cloudy',
      feelsLikeC: feels,
      humidityPercent: hum,
      windSpeedKmH: wind,
      windDirection: json['wind_direction'] ?? 'SW',
      visibilityKm: (json['visibility_km'] as num?)?.toDouble() ?? 8.0,
      pressureHpa: (json['pressure_hpa'] as num?)?.toInt() ?? 1006,
      uvIndex: (json['uv_index'] as num?)?.toInt() ?? 5,
      sunrise: json['sunrise'] ?? '5:37 AM',
      sunset: json['sunset'] ?? '6:58 PM',
      airQualityIndex: (json['aqi'] as num?)?.toInt() ?? 84,
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
