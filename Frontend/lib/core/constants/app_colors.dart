import 'package:flutter/material.dart';

/// Clean, weather-focused color palette for WeatherGPT.
/// Strictly follows light-mode friendly aesthetics with soft blue/cyan, clean light backgrounds,
/// and clear non-neon alert severity colors.
class AppColors {
  // Brand & Primary Weather Colors
  static const Color primaryBlue = Color(0xFF0F62FE);
  static const Color primaryBlueDark = Color(0xFF0043CE);
  static const Color primaryBlueLight = Color(0xFFE8F1FF);
  static const Color cyanAccent = Color(0xFF0091FF);
  static const Color skyBlue = Color(0xFF4589FF);
  static const Color tealAccent = Color(0xFF00B4D8);

  // Background & Surfaces
  static const Color backgroundLight = Color(0xFFF4F7FB);
  static const Color cardSurface = Colors.white;
  static const Color surfaceVariant = Color(0xFFEDF2F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFEEF2F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // Weather Condition Theme Gradients & Colors
  static const Color sunnyYellow = Color(0xFFF59E0B);
  static const Color sunnyBackground = Color(0xFFFFFBEB);
  static const Color rainyBlue = Color(0xFF2563EB);
  static const Color rainyBackground = Color(0xFFA5B4FC);
  static const Color cloudyGray = Color(0xFF64748B);
  static const Color stormyIndigo = Color(0xFF4338CA);

  // Non-neon Severity Alert Colors (Explicitly matching accessibility rules)
  static const Color criticalRed = Color(0xFFDC2626);
  static const Color criticalRedBg = Color(0xFFFEF2F2);
  
  static const Color severeOrange = Color(0xFFEA580C);
  static const Color severeOrangeBg = Color(0xFFFFEDD5);

  static const Color moderateYellow = Color(0xFFD97706);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color moderateYellowBg = Color(0xFFFEF3C7);

  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoBlueBg = Color(0xFFEFF6FF);

  static const Color successGreen = Color(0xFF16A34A);
  static const Color successGreenBg = Color(0xFFDCFCE7);

  // Chat UI Colors
  static const Color userBubbleBg = Color(0xFF0F62FE);
  static const Color aiBubbleBg = Colors.white;
  static const Color inputBackground = Color(0xFFF8FAFC);
}
