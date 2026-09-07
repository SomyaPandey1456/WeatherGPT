import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications marked as read.')),
              );
            },
            icon: Icon(Icons.done_all_rounded, color: context.textPrimary),
            tooltip: 'Mark all read',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationItem(
            context,
            title: 'Critical Heavy Rain Warning Issued',
            time: '10 min ago',
            body: 'IMD has issued a red warning for Delhi NCR including Greater Noida. Expect severe waterlogging.',
            icon: Icons.warning_rounded,
            iconColor: AppColors.criticalRed,
            bgColor: context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg,
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            title: 'Daily Evening Weather Digest',
            time: '2 hours ago',
            body: 'Temperature in Greater Noida dropped to 28°C. Rain expected around 4:00 PM.',
            icon: Icons.wb_sunny_rounded,
            iconColor: AppColors.primaryBlue,
            bgColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
            isUnread: true,
          ),
          _buildNotificationItem(
            context,
            title: 'Monsoon Seasonal Trend Updated',
            time: 'Yesterday',
            body: 'Climate Analysis updated with September precipitation totals for Western UP.',
            icon: Icons.auto_graph_rounded,
            iconColor: AppColors.rainyBlue,
            bgColor: context.isDark ? const Color(0xFF1B2A4A) : AppColors.infoBlueBg,
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context, {
    required String title,
    required String time,
    required String body,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? context.cardBg : context.scaffoldBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: isUnread ? AppColors.primaryBlue.withValues(alpha: 0.3) : context.borderBg),
        boxShadow: isUnread ? AppStyles.softShadow : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: context.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
