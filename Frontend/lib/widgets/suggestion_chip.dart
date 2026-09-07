import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class SuggestionChipWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const SuggestionChipWidget({
    super.key,
    required this.text,
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
            color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
            borderRadius: AppStyles.borderRadiusPill,
            border: Border.all(
              color: context.isDark ? AppColors.skyBlue.withValues(alpha: 0.3) : AppColors.primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlueDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
