import 'package:flutter/material.dart';
import '../models/forecast.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/utils/weather_utils.dart';
import '../core/theme/theme_context.dart';

class HourlyForecastTile extends StatelessWidget {
  final HourlyForecast forecast;

  const HourlyForecastTile({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final iconData = WeatherUtils.getWeatherIconData(forecast.condition);
    final isRain = forecast.rainProbability >= 40;

    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isRain
            ? (context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight)
            : context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(
          color: isRain ? AppColors.primaryBlue.withValues(alpha: 0.3) : context.borderBg,
        ),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            forecast.timeLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          Icon(
            iconData,
            size: 26,
            color: WeatherUtils.getWeatherColor(forecast.condition),
          ),
          if (forecast.rainProbability > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop_rounded, size: 10, color: AppColors.rainyBlue),
                const SizedBox(width: 2),
                Text(
                  '${forecast.rainProbability}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rainyBlue,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 12),
          Text(
            '${forecast.temperatureC.round()}°',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final VoidCallback? onTap;

  const DailyForecastTile({super.key, required this.forecast, this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = WeatherUtils.getWeatherIconData(forecast.condition);

    return InkWell(
      onTap: onTap,
      borderRadius: AppStyles.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppStyles.borderRadiusLg,
          border: Border.all(color: context.borderBg, width: 1.0),
          boxShadow: AppStyles.softShadow,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forecast.dayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    forecast.dateStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              iconData,
              size: 26,
              color: WeatherUtils.getWeatherColor(forecast.condition),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                forecast.condition,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: context.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (forecast.rainProbability > 0)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, size: 12, color: AppColors.rainyBlue),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast.rainProbability}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.rainyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Text(
                  '${forecast.highTempC.round()}°',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${forecast.lowTempC.round()}°',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
