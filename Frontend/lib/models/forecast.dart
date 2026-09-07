class HourlyForecast {
  final String timeLabel; // e.g. "12 PM", "1 PM"
  final double temperatureC;
  final String condition;
  final int rainProbability; // Percentage 0-100
  final double windSpeedKmH;

  const HourlyForecast({
    required this.timeLabel,
    required this.temperatureC,
    required this.condition,
    required this.rainProbability,
    required this.windSpeedKmH,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      timeLabel: json['time_label'] ?? '',
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      rainProbability: json['rain_probability'] ?? 0,
      windSpeedKmH: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_label': timeLabel,
      'temperature_c': temperatureC,
      'condition': condition,
      'rain_probability': rainProbability,
      'wind_speed_kmh': windSpeedKmH,
    };
  }
}

class DailyForecast {
  final String dayName; // e.g. "Today", "Fri", "Sat"
  final String dateStr; // e.g. "Sep 5"
  final String condition;
  final double highTempC;
  final double lowTempC;
  final int rainProbability;
  final String summary;
  final int humidityPercent;
  final double maxWindSpeedKmH;

  const DailyForecast({
    required this.dayName,
    required this.dateStr,
    required this.condition,
    required this.highTempC,
    required this.lowTempC,
    required this.rainProbability,
    required this.summary,
    required this.humidityPercent,
    required this.maxWindSpeedKmH,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dayName: json['day_name'] ?? '',
      dateStr: json['date_str'] ?? '',
      condition: json['condition'] ?? '',
      highTempC: (json['high_temp_c'] as num?)?.toDouble() ?? 0.0,
      lowTempC: (json['low_temp_c'] as num?)?.toDouble() ?? 0.0,
      rainProbability: json['rain_probability'] ?? 0,
      summary: json['summary'] ?? '',
      humidityPercent: json['humidity_percent'] ?? 50,
      maxWindSpeedKmH: (json['max_wind_speed_kmh'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_name': dayName,
      'date_str': dateStr,
      'condition': condition,
      'high_temp_c': highTempC,
      'low_temp_c': lowTempC,
      'rain_probability': rainProbability,
      'summary': summary,
      'humidity_percent': humidityPercent,
      'max_wind_speed_kmh': maxWindSpeedKmH,
    };
  }
}
