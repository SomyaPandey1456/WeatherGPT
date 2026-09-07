import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'navigation/app_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherGPTApp());
}

class WeatherGPTApp extends StatelessWidget {
  const WeatherGPTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'WeatherGPT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AppNavigationShell(),
        );
      },
    );
  }
}
