import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class LocationChip extends StatelessWidget {
  final String locationName;
  final String stateName;
  final VoidCallback onTap;

  const LocationChip({
    super.key,
    required this.locationName,
    required this.stateName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.borderRadiusPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppStyles.borderRadiusPill,
            border: Border.all(color: context.borderBg, width: 1),
            boxShadow: AppStyles.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '$locationName, $stateName, India',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
