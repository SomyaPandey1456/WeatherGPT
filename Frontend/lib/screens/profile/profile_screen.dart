import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const ProfileScreen({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppStyles.cleanCardDecoration,
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryBlueLight,
                    child: Icon(Icons.person_rounded, size: 48, color: AppColors.primaryBlue),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Somya Pandey',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Greater Noida, Uttar Pradesh',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // User Preferences Overview
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Personal Preferences', style: AppStyles.sectionTitle),
            ),
            const SizedBox(height: 10),
            _buildPreferenceTile(Icons.language_rounded, 'Preferred Language', 'English'),
            _buildPreferenceTile(Icons.thermostat_rounded, 'Temperature Unit', 'Celsius (°C)'),
            _buildPreferenceTile(Icons.air_rounded, 'Wind Speed Unit', 'Kilometers per hour (km/h)'),
            _buildPreferenceTile(Icons.notifications_none_rounded, 'Alert Push Notifications', 'Enabled'),
            const SizedBox(height: 20),

            // Shortcut Button to Settings
            ElevatedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Manage App Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.borderRadiusPill),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppStyles.cleanCardDecoration,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
        onTap: onOpenSettings,
      ),
    );
  }
}
