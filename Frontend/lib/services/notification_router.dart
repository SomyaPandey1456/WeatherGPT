import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../models/alert.dart';
import '../screens/alerts/alert_details_screen.dart';
import '../screens/disaster/disaster_screen.dart';
import '../screens/forecast/forecast_screen.dart';
import '../screens/climate/climate_screen.dart';
import '../screens/map/map_screen.dart';

class NotificationRouter {
  /// Centralized handler for context-aware notification navigation.
  /// Every notification taps directly to its relevant details screen/feature.
  static void handle({
    required BuildContext context,
    required NotificationItem notification,
    Function(int tabIndex)? onNavigateTab,
  }) {
    switch (notification.destination) {
      case NotificationDestination.weatherAlertDetails:
        // Use alert object from payload or create default detail alert
        final alert = notification.alertData ??
            WeatherAlert(
              id: notification.id,
              title: notification.title,
              severity: notification.type == NotificationType.heavyRain
                  ? AlertSeverity.critical
                  : AlertSeverity.severe,
              alertType: _getAlertTypeString(notification.type),
              locationName: 'Delhi NCR (Greater Noida, Noida, Ghaziabad)',
              issuedAt: 'Sep 7, 2026 - 10:30 AM',
              validUntil: 'Sep 7, 2026 - 8:00 PM',
              shortDescription: notification.message,
              fullDescription:
                  '${notification.message}\n\nThe India Meteorological Department (IMD) has issued a warning for Delhi NCR & Western UP. Continuous downpours may lead to waterlogging in low-lying urban sectors.',
              expectedDuration: '4 Hours (4:00 PM – 8:00 PM)',
              dos: const [
                'Avoid low-lying areas prone to waterlogging',
                'Carry appropriate rain protection and raincoats',
                'Check travel conditions before embarking on trips',
              ],
              donts: const [
                'Avoid unnecessary travel during peak warning hours',
                'Do not drive through flooded roads or underpasses',
              ],
              emergencyContacts: const [
                {'name': 'Disaster Helpline', 'number': '1070'},
                {'name': 'Police Control Room', 'number': '112'},
              ],
            );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlertDetailsScreen(alert: alert),
          ),
        );
        break;

      case NotificationDestination.disasterAdvisory:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DisasterScreen(),
          ),
        );
        break;

      case NotificationDestination.forecast:
        if (onNavigateTab != null) {
          onNavigateTab(1); // Forecast tab index
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForecastScreen(isStandaloneScreen: true),
            ),
          );
        }
        break;

      case NotificationDestination.climateAnalysis:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ClimateScreen(),
          ),
        );
        break;

      case NotificationDestination.weatherMap:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(),
          ),
        );
        break;
    }
  }

  static String _getAlertTypeString(NotificationType type) {
    switch (type) {
      case NotificationType.heavyRain:
        return 'Heavy Rain';
      case NotificationType.thunderstorm:
        return 'Thunderstorm';
      case NotificationType.denseFog:
        return 'Dense Fog';
      case NotificationType.lightning:
        return 'Lightning';
      case NotificationType.strongWind:
        return 'Strong Wind';
      default:
        return 'Weather Warning';
    }
  }

  /// Default notification items pre-loaded for context-aware routing
  static List<NotificationItem> get mockNotifications => [
        const NotificationItem(
          id: 'notif_001',
          title: 'Heavy Rain Warning Issued',
          message: 'Intense precipitation with gusty winds expected in Greater Noida & NCR between 4 PM - 8 PM.',
          timeAgo: '10 min ago',
          type: NotificationType.heavyRain,
          destination: NotificationDestination.weatherAlertDetails,
          isUnread: true,
        ),
        const NotificationItem(
          id: 'notif_002',
          title: 'Monsoon Flood Advisory Active',
          message: 'Urban inundation alert for Yamuna Expressway low-lying underpasses. Check safety procedures.',
          timeAgo: '45 min ago',
          type: NotificationType.flood,
          destination: NotificationDestination.disasterAdvisory,
          isUnread: true,
        ),
        const NotificationItem(
          id: 'notif_003',
          title: 'Updated 7-Day Rainfall Forecast',
          message: 'Scattered thunderstorms forecasted for Friday & Saturday. High 32°C / Low 24°C.',
          timeAgo: '2 hours ago',
          type: NotificationType.forecastUpdate,
          destination: NotificationDestination.forecast,
          isUnread: false,
        ),
        const NotificationItem(
          id: 'notif_004',
          title: 'Climate Trend Insight Published',
          message: 'Monsoon precipitation shift analysis available for Western Uttar Pradesh region.',
          timeAgo: 'Yesterday',
          type: NotificationType.climateInsight,
          destination: NotificationDestination.climateAnalysis,
          isUnread: false,
        ),
        const NotificationItem(
          id: 'notif_005',
          title: 'Radar Weather Map Alert',
          message: 'Live rain radar shows heavy storm cells approaching Greater Noida from South-West.',
          timeAgo: 'Yesterday',
          type: NotificationType.weatherMapAlert,
          destination: NotificationDestination.weatherMap,
          isUnread: false,
        ),
      ];
}
