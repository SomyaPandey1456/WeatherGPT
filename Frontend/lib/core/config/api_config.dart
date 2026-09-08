class ApiConfig {
  /// Base host URL for FastAPI server root.
  static String serverBaseUrl = 'http://10.0.2.2:8000';

  /// Base URL for FastAPI v1 API endpoints.
  static String baseUrl = 'http://10.0.2.2:8000/api/v1';

  /// Toggle mock data mode when FastAPI backend is offline.
  /// Set to false to use real FastAPI backend.
  static bool useMockData = false;

  /// Map Tile Server URL (OpenStreetMap tile template - externalized configuration)
  static String mapTileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Timeout in milliseconds for API requests.
  static const int requestTimeoutMs = 10000;

  // Endpoint paths
  static const String currentWeatherEndpoint = '/weather/current';
  static const String forecastEndpoint = '/weather/forecast';
  static const String mapEndpoint = '/weather/map';
  static const String alertsEndpoint = '/alerts';
  static const String climateHistoryEndpoint = '/climate/history';
  static const String chatEndpoint = '/chat_with_bot';
  static const String locationsEndpoint = '/locations';
  static const String advisoryEndpoint = '/advisory';
  static const String notificationsEndpoint = '/notifications';

  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Platform': 'Flutter-Mobile',
        'X-App-Version': '1.0.0',
      };
}
