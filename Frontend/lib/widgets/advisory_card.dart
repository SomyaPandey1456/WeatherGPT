import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class AdvisoryCardWidget extends StatelessWidget {
  final String title;
  final String category;
  final String recommendation;
  final String riskLevel;

  const AdvisoryCardWidget({
    super.key,
    required this.title,
    required this.category,
    required this.recommendation,
    required this.riskLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF3B271A) : AppColors.severeOrangeBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: AppColors.severeOrange.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_rounded,
                color: AppColors.severeOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.severeOrange,
                  borderRadius: AppStyles.borderRadiusPill,
                ),
                child: Text(
                  riskLevel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Recommendation:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.severeOrange,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            recommendation,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
