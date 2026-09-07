class ClimateDataPoint {
  final String label;
  final double tempValue;
  final double rainfallMm;

  const ClimateDataPoint({
    required this.label,
    required this.tempValue,
    required this.rainfallMm,
  });

  factory ClimateDataPoint.fromJson(Map<String, dynamic> json) {
    return ClimateDataPoint(
      label: json['label'] ?? '',
      tempValue: (json['temp_value'] as num?)?.toDouble() ?? 0.0,
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ClimateInsight {
  final String title;
  final String summary;
  final String detail;
  final String impactCategory;

  const ClimateInsight({
    required this.title,
    required this.summary,
    required this.detail,
    required this.impactCategory,
  });

  factory ClimateInsight.fromJson(Map<String, dynamic> json) {
    return ClimateInsight(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      detail: json['detail'] ?? '',
      impactCategory: json['impact_category'] ?? 'General',
    );
  }
}
