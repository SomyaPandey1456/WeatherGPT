import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ThemeContextExtension on BuildContext {
  /// Check if dark mode is active
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Scaffold & page background color
  Color get scaffoldBg => isDark ? const Color(0xFF0F172A) : AppColors.backgroundLight;

  /// Card & container surface color
  Color get cardBg => isDark ? const Color(0xFF1E293B) : Colors.white;

  /// Secondary surface variant (e.g. chips, inner containers)
  Color get surfaceVariantBg => isDark ? const Color(0xFF334155) : AppColors.surfaceVariant;

  /// Input background color
  Color get inputBg => isDark ? const Color(0xFF1E293B) : AppColors.inputBackground;

  /// Border color
  Color get borderBg => isDark ? const Color(0xFF334155) : AppColors.borderLight;

  /// Divider color
  Color get dividerBg => isDark ? const Color(0xFF334155) : AppColors.dividerColor;

  /// Text colors
  Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : AppColors.textPrimary;
  Color get textSecondary => isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary;
  Color get textMuted => isDark ? const Color(0xFF94A3B8) : AppColors.textMuted;
}
