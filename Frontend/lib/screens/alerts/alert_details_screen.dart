import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';

class AlertDetailsScreen extends StatelessWidget {
  final WeatherAlert alert;

  const AlertDetailsScreen({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final severity = alert.severity;
    Color headerBg;
    Color textColor;

    switch (severity) {
      case AlertSeverity.critical:
        headerBg = context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg;
        textColor = AppColors.criticalRed;
        break;
      case AlertSeverity.severe:
        headerBg = context.isDark ? const Color(0xFF3B271A) : AppColors.severeOrangeBg;
        textColor = AppColors.severeOrange;
        break;
      case AlertSeverity.moderate:
        headerBg = context.isDark ? const Color(0xFF332B1E) : AppColors.moderateYellowBg;
        textColor = AppColors.moderateYellow;
        break;
      case AlertSeverity.info:
        headerBg = context.isDark ? const Color(0xFF1B2A4A) : AppColors.infoBlueBg;
        textColor = AppColors.infoBlue;
        break;
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Alert Details', style: TextStyle(color: context.textPrimary)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weather alert link copied to clipboard.')),
              );
            },
            icon: Icon(Icons.share_rounded, color: context.textPrimary),
            tooltip: 'Share Alert',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Title Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: AppStyles.borderRadiusXl,
                border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(severity.iconSymbol, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        severity.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    alert.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: context.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alert.locationName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: context.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Expected: ${alert.expectedDuration}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Full Description
            Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
              ),
              child: Text(
                alert.fullDescription,
                style: TextStyle(fontSize: 14, color: context.textPrimary, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),

            // Safety Recommendations: Do's
            if (alert.dos.isNotEmpty) ...[
              const Text('✓ Safety Recommendations (Do)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.successGreen)),
              const SizedBox(height: 8),
              ...alert.dos.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14, color: context.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Safety Recommendations: Don'ts
            if (alert.donts.isNotEmpty) ...[
              const Text('✕ Avoid (Don\'t)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.criticalRed)),
              const SizedBox(height: 8),
              ...alert.donts.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel_rounded, color: AppColors.criticalRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(fontSize: 14, color: context.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // Emergency Contacts Directory
            if (alert.emergencyContacts.isNotEmpty) ...[
              Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 8),
              ...alert.emergencyContacts.map((contact) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: context.cardBg,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                      child: const Icon(Icons.phone_rounded, color: AppColors.primaryBlue, size: 18),
                    ),
                    title: Text(contact['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: context.textPrimary)),
                    trailing: Text(
                      contact['number'] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dialing ${contact['name']} (${contact['number']})...')),
                      );
                    },
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
