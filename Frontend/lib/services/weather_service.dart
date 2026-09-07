import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';
import '../core/config/api_config.dart';
import '../core/config/demo_config.dart';
import 'api_service.dart';

class WeatherService {
  final ApiService _apiService = ApiService();

  Future<CurrentWeather> getCurrentWeather({String? locationId}) async {
    if (!ApiConfig.useMockData) {
      try {
        final data = await _apiService.get(ApiConfig.currentWeatherEndpoint, queryParams: {'id': locationId ?? 'gnoida'});
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
    return const [
      DailyForecast(
        dayName: 'Today',
        dateStr: 'Sep 7',
        condition: 'Thunderstorm Expected',
        highTempC: 32.0,
        lowTempC: 24.0,
        rainProbability: 75,
        summary: 'Warm afternoon followed by afternoon thunderstorms and moderate rainfall in Greater Noida.',
        humidityPercent: 68,
        maxWindSpeedKmH: 24.0,
      ),
      DailyForecast(
        dayName: 'Tue',
        dateStr: 'Sep 8',
        condition: 'Heavy Rain',
        highTempC: 29.0,
        lowTempC: 23.0,
        rainProbability: 90,
        summary: 'Widespread rain likely across NCR with occasional lightning and strong winds.',
        humidityPercent: 82,
        maxWindSpeedKmH: 28.0,
      ),
      DailyForecast(
        dayName: 'Wed',
        dateStr: 'Sep 9',
        condition: 'Scattered Showers',
        highTempC: 30.0,
        lowTempC: 24.0,
        rainProbability: 60,
        summary: 'Intermittent rainfall in morning, partial clearing towards evening.',
        humidityPercent: 75,
        maxWindSpeedKmH: 18.0,
      ),
      DailyForecast(
        dayName: 'Thu',
        dateStr: 'Sep 10',
        condition: 'Partly Cloudy',
        highTempC: 33.0,
        lowTempC: 25.0,
        rainProbability: 20,
        summary: 'Pleasant weather with clear sunshine during noon hours.',
        humidityPercent: 58,
        maxWindSpeedKmH: 12.0,
      ),
      DailyForecast(
        dayName: 'Fri',
        dateStr: 'Sep 11',
        condition: 'Mostly Sunny',
        highTempC: 34.0,
        lowTempC: 26.0,
        rainProbability: 10,
        summary: 'Warm and humid day. Minimal chance of precipitation.',
        humidityPercent: 55,
        maxWindSpeedKmH: 10.0,
      ),
      DailyForecast(
        dayName: 'Sat',
        dateStr: 'Sep 12',
        condition: 'Sunny',
        highTempC: 35.0,
        lowTempC: 26.0,
        rainProbability: 5,
        summary: 'Hot afternoon with light westerly breeze.',
        humidityPercent: 50,
        maxWindSpeedKmH: 11.0,
      ),
      DailyForecast(
        dayName: 'Sun',
        dateStr: 'Sep 13',
        condition: 'Light Drizzle',
        highTempC: 32.0,
        lowTempC: 25.0,
        rainProbability: 35,
        summary: 'Overcast skies with mild drizzle in evening hours.',
        humidityPercent: 65,
        maxWindSpeedKmH: 15.0,
      ),
    ];
  }
}
