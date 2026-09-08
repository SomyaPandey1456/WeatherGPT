import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';
import '../core/config/api_config.dart';
import '../core/config/demo_config.dart';
import 'api_service.dart';

import 'location_service.dart';

class WeatherService {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  Future<CurrentWeather> getCurrentWeather({String? locationId, double? latitude, double? longitude}) async {
    if (!ApiConfig.useMockData) {
      try {
        final queryParams = <String, String>{};
        if (locationId != null) queryParams['id'] = locationId;

        if (latitude != null && longitude != null) {
          queryParams['latitude'] = latitude.toString();
          queryParams['longitude'] = longitude.toString();
        } else {
          try {
            final coords = await _locationService.getDeviceCoordinates();
            queryParams['latitude'] = coords.latitude.toString();
            queryParams['longitude'] = coords.longitude.toString();
          } catch (_) {}
        }

        final data = await _apiService.get(
          ApiConfig.currentWeatherEndpoint,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
        );
        return CurrentWeather.fromJson(data);
      } catch (_) {
        // Fallback to mock data if backend call fails
      }
    }


    // Realistic Mock Data for Greater Noida (Current Date: 7 September 2026)
    await Future.delayed(const Duration(milliseconds: 300));
    return CurrentWeather(
      location: const LocationModel(
        id: 'gnoida',
        name: 'Greater Noida',
        state: 'Uttar Pradesh',
        country: 'India',
        latitude: 28.4744,
        longitude: 77.5040,
        isCurrent: true,
        isSaved: true,
      ),
      temperatureC: 28.0,
      condition: 'Partly Cloudy',
      iconCode: 'partly_cloudy',
      feelsLikeC: 30.0,
      humidityPercent: 62,
      windSpeedKmH: 12.0,
      windDirection: 'SW',
      visibilityKm: 8.0,
      pressureHpa: 1006,
      uvIndex: 5,
      sunrise: '5:41 AM',
      sunset: '6:35 PM',
      airQualityIndex: 84,
      lastUpdated: DemoConfig.currentDate,
    );
  }

  Future<List<HourlyForecast>> getHourlyForecast() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      HourlyForecast(timeLabel: 'Now', temperatureC: 28.0, condition: 'Partly Cloudy', rainProbability: 10, windSpeedKmH: 12.0),
      HourlyForecast(timeLabel: '12 PM', temperatureC: 29.5, condition: 'Partly Cloudy', rainProbability: 15, windSpeedKmH: 14.0),
      HourlyForecast(timeLabel: '1 PM', temperatureC: 31.0, condition: 'Sunny', rainProbability: 20, windSpeedKmH: 15.0),
      HourlyForecast(timeLabel: '2 PM', temperatureC: 32.0, condition: 'Sunny', rainProbability: 25, windSpeedKmH: 16.0),
      HourlyForecast(timeLabel: '3 PM', temperatureC: 31.5, condition: 'Thunderstorm', rainProbability: 70, windSpeedKmH: 22.0),
      HourlyForecast(timeLabel: '4 PM', temperatureC: 29.0, condition: 'Heavy Rain', rainProbability: 85, windSpeedKmH: 24.0),
      HourlyForecast(timeLabel: '5 PM', temperatureC: 27.5, condition: 'Moderate Rain', rainProbability: 60, windSpeedKmH: 18.0),
      HourlyForecast(timeLabel: '6 PM', temperatureC: 26.5, condition: 'Light Rain', rainProbability: 40, windSpeedKmH: 14.0),
      HourlyForecast(timeLabel: '7 PM', temperatureC: 26.0, condition: 'Cloudy', rainProbability: 20, windSpeedKmH: 10.0),
    ];
  }

  Future<List<DailyForecast>> get7DayForecast() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    const dayAbbrevs = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final conditions = [
      ('Thunderstorm Expected', 32.0, 24.0, 75, 'Warm afternoon followed by afternoon thunderstorms and moderate rainfall.', 68, 24.0),
      ('Heavy Rain', 29.0, 23.0, 90, 'Widespread rain likely across your area with occasional lightning.', 82, 28.0),
      ('Scattered Showers', 30.0, 24.0, 60, 'Intermittent rainfall in morning, partial clearing towards evening.', 75, 18.0),
      ('Partly Cloudy', 33.0, 25.0, 20, 'Pleasant weather with clear sunshine during noon hours.', 58, 12.0),
      ('Mostly Sunny', 34.0, 26.0, 10, 'Warm and humid day. Minimal chance of precipitation.', 55, 10.0),
      ('Sunny', 35.0, 26.0, 5, 'Hot afternoon with light westerly breeze.', 50, 11.0),
      ('Light Drizzle', 32.0, 25.0, 35, 'Overcast skies with mild drizzle in evening hours.', 65, 15.0),
    ];

    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final dayName = i == 0 ? 'Today' : (i == 1 ? 'Tomorrow' : dayAbbrevs[(date.weekday - 1) % 7]);
      final dateStr = '${monthNames[(date.month - 1) % 12]} ${date.day}';
      final c = conditions[i % conditions.length];

      return DailyForecast(
        dayName: dayName,
        dateStr: dateStr,
        condition: c.$1,
        highTempC: c.$2,
        lowTempC: c.$3,
        rainProbability: c.$4,
        summary: c.$5,
        humidityPercent: c.$6,
        maxWindSpeedKmH: c.$7,
      );
    });
  }
}
