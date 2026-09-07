import 'alert.dart';

enum NotificationType {
  heavyRain,
  thunderstorm,
  denseFog,
  lightning,
  strongWind,
  cyclone,
  flood,
  heatwave,
  coldWave,
  generalDisaster,
  safetyAdvisory,
  forecastUpdate,
  rainForecast,
  tempForecast,
  climateInsight,
  weatherMapAlert,
  currentWeatherAlert,
}

enum NotificationDestination {
  weatherAlertDetails,
  disasterAdvisory,
  forecast,
  climateAnalysis,
  weatherMap,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final NotificationType type;
  final NotificationDestination destination;
  final bool isUnread;
  final WeatherAlert? alertData;
  final Map<String, dynamic>? payload;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
    required this.destination,
    this.isUnread = true,
    this.alertData,
    this.payload,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timeAgo: json['time_ago'] ?? 'Just now',
      type: _parseType(json['type']),
      destination: _parseDestination(json['destination']),
      isUnread: json['is_unread'] ?? true,
      payload: json['payload'],
    );
  }

  static NotificationType _parseType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'heavy_rain':
        return NotificationType.heavyRain;
      case 'thunderstorm':
        return NotificationType.thunderstorm;
      case 'cyclone':
        return NotificationType.cyclone;
      case 'flood':
        return NotificationType.flood;
      case 'heatwave':
        return NotificationType.heatwave;
      case 'forecast':
        return NotificationType.forecastUpdate;
      case 'climate':
        return NotificationType.climateInsight;
      case 'map':
        return NotificationType.weatherMapAlert;
      default:
        return NotificationType.currentWeatherAlert;
    }
  }

  static NotificationDestination _parseDestination(String? destStr) {
    switch (destStr?.toLowerCase()) {
      case 'disaster':
        return NotificationDestination.disasterAdvisory;
      case 'forecast':
        return NotificationDestination.forecast;
      case 'climate':
        return NotificationDestination.climateAnalysis;
      case 'map':
        return NotificationDestination.weatherMap;
      default:
        return NotificationDestination.weatherAlertDetails;
    }
  }
}
