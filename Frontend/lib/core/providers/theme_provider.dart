import 'package:flutter/material.dart';

/// Simple ValueNotifier-based theme provider.
/// Allows any widget deep in the tree to change the app's ThemeMode
/// without requiring a full state management solution.
class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.light);

  ThemeMode get themeMode => value;

  void setLight() => value = ThemeMode.light;
  void setDark() => value = ThemeMode.dark;
  void setSystem() => value = ThemeMode.system;

  void setMode(ThemeMode mode) => value = mode;

  String get label {
    switch (value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

/// Global singleton accessible without context.
final themeProvider = ThemeProvider();
