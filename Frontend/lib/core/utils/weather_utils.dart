import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class WeatherUtils {
  static IconData getWeatherIconData(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) {
      return Icons.wb_sunny_rounded;
    } else if (lower.contains('rain') || lower.contains('drizzle') || lower.contains('shower')) {
      return Icons.umbrella_rounded;
    } else if (lower.contains('thunder') || lower.contains('storm')) {
      return Icons.thunderstorm_rounded;
    } else if (lower.contains('cloud') || lower.contains('overcast')) {
      return Icons.cloud_rounded;
    } else if (lower.contains('fog') || lower.contains('mist') || lower.contains('haze')) {
      return Icons.cloud_queue_rounded;
    } else if (lower.contains('snow')) {
      return Icons.ac_unit_rounded;
    } else if (lower.contains('wind')) {
      return Icons.air_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }

  static Color getWeatherColor(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('clear')) {
      return AppColors.sunnyYellow;
    } else if (lower.contains('rain') || lower.contains('shower')) {
      return AppColors.rainyBlue;
    } else if (lower.contains('thunder')) {
      return AppColors.stormyIndigo;
    }
    return AppColors.skyBlue;
  }

  static String getAqiDescription(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static Color getAqiColor(int aqi) {
    if (aqi <= 50) return AppColors.successGreen;
    if (aqi <= 100) return AppColors.moderateYellow;
    if (aqi <= 150) return AppColors.severeOrange;
    return AppColors.criticalRed;
  }

  static String getUvLevel(int uvIndex) {
    if (uvIndex <= 2) return 'Low';
    if (uvIndex <= 5) return 'Moderate';
    if (uvIndex <= 7) return 'High';
    if (uvIndex <= 10) return 'Very High';
    return 'Extreme';
  }
}
