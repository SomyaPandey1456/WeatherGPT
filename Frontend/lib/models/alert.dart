enum AlertSeverity {
  critical,
  severe,
  moderate,
  info,
}

extension AlertSeverityExtension on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.critical:
        return 'CRITICAL';
      case AlertSeverity.severe:
        return 'SEVERE';
      case AlertSeverity.moderate:
        return 'MODERATE';
      case AlertSeverity.info:
        return 'INFORMATION';
    }
  }

  String get iconSymbol {
    switch (this) {
      case AlertSeverity.critical:
        return '🔴';
      case AlertSeverity.severe:
        return '🟠';
      case AlertSeverity.moderate:
        return '🟡';
      case AlertSeverity.info:
        return '🔵';
    }
  }
}

class WeatherAlert {
  final String id;
  final String title;
  final AlertSeverity severity;
  final String alertType; // e.g., Heavy Rain, Thunderstorm, Cyclone, Flood, Heatwave
  final String locationName;
  final String issuedAt;
  final String validUntil;
  final String shortDescription;
  final String fullDescription;
  final String expectedDuration;
  final List<String> dos;
  final List<String> donts;
  final List<Map<String, String>> emergencyContacts;

  const WeatherAlert({
    required this.id,
    required this.title,
    required this.severity,
    required this.alertType,
    required this.locationName,
    required this.issuedAt,
    required this.validUntil,
    required this.shortDescription,
    required this.fullDescription,
    required this.expectedDuration,
    required this.dos,
    required this.donts,
    required this.emergencyContacts,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      severity: _parseSeverity(json['severity']),
      alertType: json['alert_type'] ?? 'General Weather Warning',
      locationName: json['location_name'] ?? 'Delhi NCR',
      issuedAt: json['issued_at'] ?? '',
      validUntil: json['valid_until'] ?? '',
      shortDescription: json['short_description'] ?? '',
      fullDescription: json['full_description'] ?? '',
      expectedDuration: json['expected_duration'] ?? '',
      dos: List<String>.from(json['dos'] ?? []),
      donts: List<String>.from(json['donts'] ?? []),
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
    );
  }

  static AlertSeverity _parseSeverity(String? value) {
    switch (value?.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'severe':
        return AlertSeverity.severe;
      case 'moderate':
        return AlertSeverity.moderate;
      default:
        return AlertSeverity.info;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'severity': severity.name,
      'alert_type': alertType,
      'location_name': locationName,
      'issued_at': issuedAt,
      'valid_until': validUntil,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'expected_duration': expectedDuration,
      'dos': dos,
      'donts': donts,
      'emergency_contacts': emergencyContacts,
    };
  }
}
