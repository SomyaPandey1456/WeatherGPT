import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';
import '../models/notification_item.dart';
import '../services/notification_router.dart';

class NotificationPanelWidget extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const NotificationPanelWidget({super.key, this.onNavigateTab});

  static void show(BuildContext context, {Function(int tabIndex)? onNavigateTab}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: context.cardBg,
      builder: (context) => NotificationPanelWidget(onNavigateTab: onNavigateTab),
    );
  }

  @override
  State<NotificationPanelWidget> createState() => _NotificationPanelWidgetState();
}

class _NotificationPanelWidgetState extends State<NotificationPanelWidget> {
  final List<NotificationItem> _notifications = NotificationRouter.mockNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Handle Bar & Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderBg,
                borderRadius: AppStyles.borderRadiusPill,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Weather Alerts & Updates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: context.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap any alert to jump directly to its complete report.',
            style: TextStyle(fontSize: 12, color: context.textMuted),
          ),
          const SizedBox(height: 14),

          // Notifications List
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _buildNotificationTile(context, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationItem item) {
    Color iconBg;
    Color iconColor;
    IconData icon;

    switch (item.destination) {
      case NotificationDestination.weatherAlertDetails:
        iconBg = context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg;
        iconColor = AppColors.criticalRed;
        icon = Icons.warning_rounded;
        break;
      case NotificationDestination.disasterAdvisory:
        iconBg = context.isDark ? const Color(0xFF3B271A) : AppColors.severeOrangeBg;
        iconColor = AppColors.severeOrange;
        icon = Icons.shield_rounded;
        break;
      case NotificationDestination.forecast:
        iconBg = context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight;
        iconColor = AppColors.primaryBlue;
        icon = Icons.calendar_today_rounded;
        break;
      case NotificationDestination.climateAnalysis:
        iconBg = context.isDark ? const Color(0xFF1B2A4A) : AppColors.infoBlueBg;
        iconColor = AppColors.rainyBlue;
        icon = Icons.auto_graph_rounded;
        break;
      case NotificationDestination.weatherMap:
        iconBg = context.isDark ? const Color(0xFF1E2F38) : AppColors.primaryBlueLight;
        iconColor = AppColors.tealAccent;
        icon = Icons.map_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: item.isUnread ? context.cardBg : context.scaffoldBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: item.isUnread ? AppColors.primaryBlue.withValues(alpha: 0.3) : context.borderBg),
        boxShadow: item.isUnread ? AppStyles.softShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppStyles.borderRadiusLg,
        child: InkWell(
          borderRadius: AppStyles.borderRadiusLg,
          onTap: () {
            Navigator.pop(context); // Close panel
            NotificationRouter.handle(
              context: context,
              notification: item,
              onNavigateTab: widget.onNavigateTab,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
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
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: item.isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item.timeAgo,
                            style: TextStyle(fontSize: 11, color: context.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Text(
                            'Tap to view details',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primaryBlue),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
