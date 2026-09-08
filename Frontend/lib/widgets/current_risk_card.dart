import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';
import '../services/risk_service.dart';

class CurrentRiskCardWidget extends StatelessWidget {
  final RiskModel risk;
  final VoidCallback? onRefresh;

  const CurrentRiskCardWidget({
    super.key,
    required this.risk,
    this.onRefresh,
  });

  Color _getBadgeColor() {
    switch (risk.level.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.criticalRed;
      case 'HIGH':
        return AppColors.warningAmber;
      case 'MODERATE':
        return AppColors.primaryBlue;
      case 'LOW':
      default:
        return AppColors.successGreen;
    }
  }

  IconData _getRiskIcon() {
    switch (risk.level.toUpperCase()) {
      case 'CRITICAL':
        return Icons.dangerous_rounded;
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MODERATE':
        return Icons.info_rounded;
      case 'LOW':
      default:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getRiskIcon(), color: badgeColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'CURRENT RISK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: AppStyles.borderRadiusPill,
                  border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  risk.level.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hazard Title
          Text(
            risk.hazard,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Description Message
          Text(
            risk.message,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Action Recommendation
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
              borderRadius: AppStyles.borderRadiusMd,
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    risk.recommendedAction,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.isDark ? Colors.white : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
