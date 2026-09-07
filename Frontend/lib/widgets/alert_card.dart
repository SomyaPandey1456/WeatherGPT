import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class AlertCard extends StatelessWidget {
  final WeatherAlert alert;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severity = alert.severity;
    Color borderBgColor;
    Color chipBgColor;
    Color textColor;

    switch (severity) {
      case AlertSeverity.critical:
        borderBgColor = AppColors.criticalRed;
        chipBgColor = context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg;
        textColor = AppColors.criticalRed;
        break;
      case AlertSeverity.severe:
        borderBgColor = AppColors.severeOrange;
        chipBgColor = context.isDark ? const Color(0xFF3B271A) : AppColors.severeOrangeBg;
        textColor = AppColors.severeOrange;
        break;
      case AlertSeverity.moderate:
        borderBgColor = AppColors.moderateYellow;
        chipBgColor = context.isDark ? const Color(0xFF332B1E) : AppColors.moderateYellowBg;
        textColor = AppColors.moderateYellow;
        break;
      case AlertSeverity.info:
        borderBgColor = AppColors.infoBlue;
        chipBgColor = context.isDark ? const Color(0xFF1B2A4A) : AppColors.infoBlueBg;
        textColor = AppColors.infoBlue;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: borderBgColor.withValues(alpha: 0.4), width: 1.5),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppStyles.borderRadiusLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppStyles.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipBgColor,
                        borderRadius: AppStyles.borderRadiusPill,
                        border: Border.all(color: textColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            severity.iconSymbol,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            severity.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: context.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          alert.validUntil,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: context.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alert.locationName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alert.shortDescription,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View safety details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: textColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
