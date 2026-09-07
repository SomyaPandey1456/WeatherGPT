import '../models/alert.dart';
import '../core/config/demo_config.dart';

class AlertService {
  Future<List<WeatherAlert>> getActiveAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      WeatherAlert(
        id: 'alert_001',
        title: 'HEAVY RAIN WARNING',
        severity: AlertSeverity.critical,
        alertType: 'Heavy Rain',
        locationName: 'Delhi NCR (Greater Noida, Noida, Ghaziabad)',
        issuedAt: '${DemoConfig.todayStr} - 10:30 AM',
        validUntil: '${DemoConfig.todayStr} - 8:00 PM',
        shortDescription: 'Intense precipitation with gusty winds expected between 4:00 PM and 8:00 PM.',
        fullDescription:
            'The India Meteorological Department (IMD) has issued a Critical Heavy Rain Warning for Delhi NCR. Continuous downpours may lead to waterlogging in low-lying urban areas and severe traffic congestion along main expressways.',
        expectedDuration: '4 Hours (4:00 PM – 8:00 PM)',
        dos: const [
          'Avoid low-lying areas prone to waterlogging',
          'Carry appropriate rain protection and raincoats',
          'Check travel conditions before embarking on trips',
          'Keep mobile phones charged in case of local power disruptions'
        ],
        donts: const [
          'Avoid unnecessary travel during peak warning hours',
          'Do not drive through flooded roads or underpasses',
          'Do not take shelter under trees or weak structures during lightning',
          'Do not touch exposed electrical cables or poles'
        ],
        emergencyContacts: const [
          {'name': 'Disaster Management Helpline', 'number': '1070'},
          {'name': 'State Emergency Operation Centre', 'number': '0120-230000'},
          {'name': 'Ambulance Services', 'number': '108'},
          {'name': 'Police Control Room', 'number': '112'},
        ],
      ),
      WeatherAlert(
        id: 'alert_002',
        title: 'THUNDERSTORM & LIGHTNING ALERT',
        severity: AlertSeverity.severe,
        alertType: 'Thunderstorm',
        locationName: 'Western Uttar Pradesh & Haryana',
        issuedAt: '${DemoConfig.todayStr} - 11:00 AM',
        validUntil: '${DemoConfig.todayStr} - 6:00 PM',
        shortDescription: 'Moderate to severe thunderstorm accompanied by cloud-to-ground lightning.',
        fullDescription:
            'Atmospheric instability over Western UP is leading to cloud formation with high lightning risk. Sudden wind gusts up to 45 km/h are expected.',
        expectedDuration: '6 Hours',
        dos: const [
          'Stay indoors inside sturdy buildings',
          'Unplug sensitive electronic devices',
          'Stay away from windows and balcony railings'
        ],
        donts: const [
          'Do not open metallic umbrellas outdoors',
          'Do not stand in open fields or near high towers'
        ],
        emergencyContacts: const [
          {'name': 'Disaster Helpline', 'number': '1070'},
        ],
      ),
      WeatherAlert(
        id: 'alert_003',
        title: 'HIGH HUMIDITY & HEAT ADVISORY',
        severity: AlertSeverity.moderate,
        alertType: 'Heatwave',
        locationName: 'Greater Noida & Surrounding Areas',
        issuedAt: '${DemoConfig.todayStr} - 8:00 AM',
        validUntil: '${DemoConfig.todayStr} - 3:30 PM',
        shortDescription: 'Heat index reaching 36°C with 65% relative humidity.',
        fullDescription: 'High humidity combined with elevated midday temperatures will create sticky, uncomfortable outdoor conditions prior to afternoon rains.',
        expectedDuration: '7 Hours',
        dos: const ['Drink plenty of water and hydration fluids', 'Wear light cotton clothing'],
        donts: const ['Avoid direct sun exposure without protection between 12 PM - 3 PM'],
        emergencyContacts: const [
          {'name': 'Medical Emergency', 'number': '102'},
        ],
      ),
    ];
  }
}
