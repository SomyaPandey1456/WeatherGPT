import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';
import '../services/risk_service.dart';

class DisasterAlertCardWidget extends StatelessWidget {
  final RiskModel risk;
  final VoidCallback? onTapAction;

  const DisasterAlertCardWidget({
    super.key,
    required this.risk,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    if (risk.level == 'LOW') {
      return const SizedBox.shrink();
    }

    final isCritical = risk.level == 'CRITICAL' || risk.level == 'HIGH';
    final alertColor = isCritical ? AppColors.criticalRed : AppColors.warningAmber;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark
            ? (isCritical ? const Color(0xFF3B1C1C) : const Color(0xFF3B2F1C))
            : (isCritical ? AppColors.criticalRedBg : const Color(0xFFFFF8E6)),
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: alertColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCritical ? Icons.campaign_rounded : Icons.warning_amber_rounded,
                color: alertColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠️ ACTIVE WEATHER ALERT (${risk.level})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: alertColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            risk.hazard,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            risk.message,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommended: ${risk.recommendedAction}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: alertColor,
                ),
              ),
              if (onTapAction != null)
                InkWell(
                  onTap: onTapAction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          'Help Page',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: alertColor,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 14, color: alertColor),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
