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
    if (!ApiConfig.useMockData) {
      try {
        final queryParams = <String, String>{};
        try {
          final coords = await _locationService.getDeviceCoordinates();
          queryParams['latitude'] = coords.latitude.toString();
          queryParams['longitude'] = coords.longitude.toString();
        } catch (_) {}

        final data = await _apiService.get('/weather/hourly', queryParams: queryParams.isNotEmpty ? queryParams : null);

        if (data is Map<String, dynamic> && data.containsKey('hourly')) {
          final list = data['hourly'] as List;
          final now = DateTime.now();
          final results = <HourlyForecast>[];

          for (int i = 0; i < list.length; i++) {
            final item = list[i] as Map<String, dynamic>;
            final timeStr = item['time']?.toString();
            if (timeStr == null) continue;
            final dt = DateTime.tryParse(timeStr)?.toLocal();
            if (dt == null) continue;

            // Only include current hour and future hours
            if (dt.isBefore(now.subtract(const Duration(minutes: 55)))) continue;

            String label;
            if (results.isEmpty) {
              label = 'Now';
            } else {
              final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
              final ampm = dt.hour >= 12 ? 'PM' : 'AM';
              label = '$hour12 $ampm';
            }

            final temp = (item['temperature'] as num?)?.toDouble() ?? 28.0;
            final rainProb = (item['precipitation_probability'] as num?)?.toInt() ?? 10;
            final wind = (item['wind_speed'] as num?)?.toDouble() ?? 12.0;
            final weatherCode = (item['weather_code'] as num?)?.toInt() ?? 0;

            String cond = 'Partly Cloudy';
            if ([1, 2, 3].contains(weatherCode)) {
              cond = 'Partly Cloudy';
            } else if ([51, 53, 55, 61, 63, 65, 80, 81].contains(weatherCode)) {
              cond = 'Rain Showers';
            } else if ([95, 96, 99].contains(weatherCode)) {
              cond = 'Thunderstorm';
            } else if (weatherCode == 0) {
              cond = 'Sunny';
            }


            results.add(HourlyForecast(
              timeLabel: label,
              temperatureC: temp,
              condition: cond,
              rainProbability: rainProb,
              windSpeedKmH: wind,
            ));

            if (results.length >= 12) break; // Limit to next 12 hours
          }

          if (results.isNotEmpty) return results;
        }
      } catch (_) {
        // Fallback to dynamic local hour sequence if API call fails
      }
    }

    // Dynamic fallback generation starting from actual local hour
    final now = DateTime.now();
    return List.generate(8, (index) {
      if (index == 0) {
        return const HourlyForecast(
          timeLabel: 'Now',
          temperatureC: 28.0,
          condition: 'Partly Cloudy',
          rainProbability: 10,
          windSpeedKmH: 12.0,
        );
      }
      final target = now.add(Duration(hours: index));
      final hour12 = target.hour % 12 == 0 ? 12 : target.hour % 12;
      final ampm = target.hour >= 12 ? 'PM' : 'AM';
      final label = '$hour12 $ampm';
      final temp = 28.0 + (index % 3) - 1.0;

      return HourlyForecast(
        timeLabel: label,
        temperatureC: temp,
        condition: index == 4 ? 'Thunderstorm' : 'Partly Cloudy',
        rainProbability: index == 4 ? 75 : 15,
        windSpeedKmH: 12.0 + index,
      );
    });
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
