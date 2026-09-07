import 'weather.dart';
import 'forecast.dart';
import 'alert.dart';

enum ResponseContentType {
  textOnly,
  weatherCard,
  forecastCard,
  alertCard,
  advisoryCard,
}

class StructuredResponseContent {
  final ResponseContentType type;
  final CurrentWeather? currentWeather;
  final List<HourlyForecast>? hourlyForecasts;
  final WeatherAlert? alert;
  final Map<String, String>? advisoryData;

  const StructuredResponseContent({
    required this.type,
    this.currentWeather,
    this.hourlyForecasts,
    this.alert,
    this.advisoryData,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final StructuredResponseContent? structuredContent;
  final bool isError;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.structuredContent,
    this.isError = false,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.ai(String text, {StructuredResponseContent? structuredContent}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      structuredContent: structuredContent,
    );
  }
}
