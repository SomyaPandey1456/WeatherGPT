import '../models/climate.dart';

class ClimateService {
  Future<List<ClimateDataPoint>> getHistoricalTrends({String range = '1 Year'}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      ClimateDataPoint(label: 'Jan', tempValue: 15.2, rainfallMm: 22.0),
      ClimateDataPoint(label: 'Feb', tempValue: 19.4, rainfallMm: 18.0),
      ClimateDataPoint(label: 'Mar', tempValue: 25.8, rainfallMm: 15.0),
      ClimateDataPoint(label: 'Apr', tempValue: 32.1, rainfallMm: 10.0),
      ClimateDataPoint(label: 'May', tempValue: 38.5, rainfallMm: 35.0),
      ClimateDataPoint(label: 'Jun', tempValue: 39.2, rainfallMm: 85.0),
      ClimateDataPoint(label: 'Jul', tempValue: 34.0, rainfallMm: 240.0),
      ClimateDataPoint(label: 'Aug', tempValue: 32.8, rainfallMm: 210.0),
      ClimateDataPoint(label: 'Sep', tempValue: 31.5, rainfallMm: 145.0),
      ClimateDataPoint(label: 'Oct', tempValue: 27.2, rainfallMm: 25.0),
      ClimateDataPoint(label: 'Nov', tempValue: 21.0, rainfallMm: 8.0),
      ClimateDataPoint(label: 'Dec', tempValue: 16.1, rainfallMm: 12.0),
    ];
  }

  Future<List<ClimateInsight>> getClimateInsights() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      ClimateInsight(
        title: 'Monsoon Precipitation Shift',
        summary: 'Monsoon rainfall in Greater Noida & Western UP shows 14% higher intensity short-duration rain bursts.',
        detail: 'Historical comparison over the past 5 years indicates that while overall seasonal rainfall totals remain consistent, single-day heavy rainfall events have increased by 22%, requiring urban storm drainage preparation.',
        impactCategory: 'Monsoon Analysis',
      ),
      ClimateInsight(
        title: 'Average Annual Temperature Trend',
        summary: 'Mean summer temperatures have risen by +0.8°C over the past decade.',
        detail: 'Analysis of meteorological records demonstrates an upward shift in nighttime minimum temperatures during May-June, leading to prolonged heat retention in built urban environments.',
        impactCategory: 'Heat Trends',
      ),
    ];
  }
}
