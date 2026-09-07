import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/utils/weather_utils.dart';
import '../core/theme/theme_context.dart';

class WeatherCard extends StatelessWidget {
  final CurrentWeather weather;
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = WeatherUtils.getWeatherIconData(weather.condition);
    final themeColor = WeatherUtils.getWeatherColor(weather.condition);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.cardBg,
              context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight.withValues(alpha: 0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.borderRadiusXl,
          border: Border.all(color: context.borderBg, width: 1),
          boxShadow: AppStyles.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.location.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.condition,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    size: 36,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${weather.temperatureC.round()}°C',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Feels like ${weather.feelsLikeC.round()}°C',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: context.borderBg, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuickMetric(context, Icons.water_drop_rounded, '${weather.humidityPercent}%', 'Humidity'),
                _buildQuickMetric(context, Icons.air_rounded, '${weather.windSpeedKmH.round()} km/h', 'Wind'),
                _buildQuickMetric(context, Icons.wb_sunny_rounded, 'UV ${weather.uvIndex}', 'UV Index'),
                _buildQuickMetric(context, Icons.thermostat_rounded, 'AQI ${weather.airQualityIndex}', WeatherUtils.getAqiDescription(weather.airQualityIndex)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetric(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: context.textMuted,
          ),
        ),
      ],
    );
  }
}
