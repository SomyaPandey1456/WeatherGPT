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
    'Will it rain today?',
    'Any active alerts for my area?',
    'Weather forecast for this week',
    'Is it safe to travel today?',
    'How hot will it be today?',
    'Monsoon and storm forecast'
  ];

  // Recent Queries
  static const List<Map<String, String>> defaultRecentQueries = [
    {'query': 'Will it rain today?', 'time': '2 min ago'},
    {'query': 'Rain alerts for my current area', 'time': '1 hr ago'},
    {'query': 'Temperature forecast for today', 'time': 'Yesterday'},
  ];

  // Quick Action Titles
  static const String quickWeatherNow = 'Weather Now';
  static const String quickForecast = 'Forecast';
  static const String quickMap = 'Weather Map';
  static const String quickAlerts = 'Alerts';
  static const String quickClimate = 'Climate Analysis';
  static const String quickDisaster = 'Disaster Advisory';
}
