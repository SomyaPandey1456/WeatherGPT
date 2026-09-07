class AppStrings {
  static const String appName = 'WeatherGPT';
  static const String tagline = 'Conversational Weather Intelligence';
  
  // Default Location
  static const String defaultLocationName = 'Greater Noida';
  static const String defaultLocationState = 'Uttar Pradesh';
  static const String defaultLocationCountry = 'India';

  // AI Search Prompts
  static const String askAnythingTitle = 'Ask anything about weather';
  static const String askAnythingSubtitle = 'Get real-time updates, forecasts, alerts and more';
  static const String inputPlaceholder = 'Ask about weather...';

  // Suggested Questions
  static const List<String> defaultSuggestions = [
    'Will it rain today (7 Sep)?',
    'Any alerts for my area?',
    'Weather forecast for 7-13 Sep',
    'Is it safe to travel today?',
    'How hot will it be today?',
    'Monsoon forecast for North India'
  ];

  // Recent Queries (Aligned with 7 September 2026)
  static const List<Map<String, String>> defaultRecentQueries = [
    {'query': 'Will it rain in Greater Noida today?', 'time': '2 min ago'},
    {'query': 'Rain alerts in Delhi NCR for 7 Sep', 'time': '1 hr ago'},
    {'query': 'Temperature forecast for 7 Sep', 'time': 'Yesterday (6 Sep)'},
  ];

  // Quick Action Titles
  static const String quickWeatherNow = 'Weather Now';
  static const String quickForecast = 'Forecast';
  static const String quickMap = 'Weather Map';
  static const String quickAlerts = 'Alerts';
  static const String quickClimate = 'Climate Analysis';
  static const String quickDisaster = 'Disaster Advisory';
}
