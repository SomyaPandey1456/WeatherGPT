import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../core/config/api_config.dart';

import 'api_service.dart';
import 'weather_service.dart';
import 'alert_service.dart';
import 'location_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();
  final WeatherService _weatherService = WeatherService();
  final AlertService _alertService = AlertService();
  final LocationService _locationService = LocationService();

  Future<ChatMessage> sendQuery(String query) async {
    final lower = query.toLowerCase();

    if (!ApiConfig.useMockData) {
      try {
        final coords = await _locationService.getDeviceCoordinates();
        debugPrint('🤖 CHAT LOCATION CONTEXT\nlatitude = ${coords.latitude}\nlongitude = ${coords.longitude}');

        final responseData = await _apiService.post(ApiConfig.chatEndpoint, {
          'user': query,
          'lat': coords.latitude,
          'long': coords.longitude,
          'latitude': coords.latitude,
          'longitude': coords.longitude,
          'city': _locationService.currentCity,
        });

        final parsedText = _parseBackendResponse(responseData);
        return ChatMessage.ai(parsedText);
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        throw ApiException('Failed to get response from WeatherGPT: $e');
      }
    }


    await Future.delayed(const Duration(milliseconds: 600));

    // Dynamic intelligent structured AI responses matching user intents
    if (lower.contains('rain') || lower.contains('umbrella') || lower.contains('shower')) {
      final hourly = await _weatherService.getHourlyForecast();
      return ChatMessage.ai(
        'Yes, rain is expected in Greater Noida today. Heavy downpours are anticipated between 3:00 PM and 6:00 PM with a peak 85% probability around 4 PM. I advise carrying an umbrella if stepping outdoor.',
        structuredContent: StructuredResponseContent(
          type: ResponseContentType.forecastCard,
          hourlyForecasts: hourly,
        ),
      );
    } else if (lower.contains('alert') || lower.contains('warning') || lower.contains('hazard')) {
      final alerts = await _alertService.getActiveAlerts();
      final topAlert = alerts.first;
      return ChatMessage.ai(
        'There is currently 1 Critical Heavy Rain Alert issued for your area (Delhi NCR / Greater Noida) valid until 8:00 PM today. Please see details below:',
        structuredContent: StructuredResponseContent(
          type: ResponseContentType.alertCard,
          alert: topAlert,
        ),
      );
    } else if (lower.contains('travel') || lower.contains('safe') || lower.contains('road')) {
      return ChatMessage.ai(
        '🚗 **Travel Advisory for Greater Noida & NCR**:\n\nHeavy rain & waterlogging expected on Yamuna Expressway and Noida-Greater Noida Expressway between 4 PM and 8 PM.\n\n**Recommendation:** Complete your transit before 3:00 PM or delay non-essential travel until after 8:30 PM.',
        structuredContent: const StructuredResponseContent(
          type: ResponseContentType.advisoryCard,
          advisoryData: {
            'title': 'Travel Advisory',
            'category': 'Road Safety',
            'recommendation': 'Consider travelling before 3:00 PM to avoid heavy evening waterlogging.',
            'risk_level': 'Moderate-High',
          },
        ),
      );
    } else if (lower.contains('hot') || lower.contains('temp') || lower.contains('weather') || lower.contains('now')) {
      final currentWeather = await _weatherService.getCurrentWeather();
      return ChatMessage.ai(
        'Currently in Greater Noida, it is 28°C with Partly Cloudy skies. Feels like 30°C due to 62% humidity. Wind is blowing from SW at 12 km/h.',
        structuredContent: StructuredResponseContent(
          type: ResponseContentType.weatherCard,
          currentWeather: currentWeather,
        ),
      );
    }

    return ChatMessage.ai(
      'Based on WeatherGPT intelligence for Greater Noida: Expect warm weather early today reaching up to 32°C, followed by thunderstorm activity later in the afternoon. Air quality is currently Moderate (AQI 84). Feel free to ask about specific hourly forecasts or rain warnings!',
    );
  }

  /// Parses the raw response from FastAPI backend into clean human-readable text.
  String _parseBackendResponse(dynamic responseData) {
    if (responseData == null) {
      return 'No response received from WeatherGPT.';
    }

    if (responseData is String) {
      // Check if the string itself is JSON-encoded
      try {
        final decoded = jsonDecode(responseData);
        if (decoded is Map) {
          return decoded['response'] ?? decoded['text'] ?? decoded['message'] ?? responseData;
        }
      } catch (_) {}
      return responseData;
    }

    if (responseData is Map) {
      return responseData['response'] ??
          responseData['text'] ??
          responseData['message'] ??
          responseData.toString();
    }

    return responseData.toString();
  }
}
