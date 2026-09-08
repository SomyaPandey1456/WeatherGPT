import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';

class NdrfEmergencyCard extends StatelessWidget {
  const NdrfEmergencyCard({super.key});

  Future<void> _makePhoneCall(BuildContext context, String rawNumber, String displayLabel) async {
    final cleanNum = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNum');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Unable to open the phone app on this device.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Unable to open the phone app on this device.');
      }
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent('WeatherGPT Disaster Assistance')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'No email application is available.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'No email application is available.');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.criticalRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(
          color: AppColors.criticalRed.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.criticalRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          '🚨 Contact NDRF',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.criticalRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '8th Battalion NDRF, Ghaziabad',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primaryBlue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Kamla Nehru Nagar, Ghaziabad, UP',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Emergency Action Buttons Section
          Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // 1. Primary Call Button (Visually Prominent)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(context, '01202766618', 'Main Phone'),
              icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
              label: const Text(
                '📞 Call NDRF (0120-2766618)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.criticalRed,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Mobile & Control Room Call Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(context, '09412221035', 'Mobile'),
                  icon: const Icon(Icons.phone_android_rounded, size: 16, color: AppColors.primaryBlue),
                  label: const Text(
                    '📱 Call Mobile\n09412221035',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(context, '01202766013', 'Control Room'),
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.severeOrange),
                  label: const Text(
                    '🚨 Control Room\n0120-2766013',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.severeOrange,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    side: const BorderSide(color: AppColors.severeOrange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: context.borderBg),
          const SizedBox(height: 12),

          // NDRF Headquarters Section
          Text(
            'NDRF HQ Control Room (New Delhi)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(context, '01123438091', 'NDRF HQ Line 1'),
                  icon: const Icon(Icons.business_rounded, size: 15, color: AppColors.primaryBlue),
                  label: const Text(
                    '📞 011-23438091',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: context.borderBg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(context, '01123438136', 'NDRF HQ Line 2'),
                  icon: const Icon(Icons.business_rounded, size: 15, color: AppColors.primaryBlue),
                  label: const Text(
                    '📞 011-23438136',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: context.borderBg),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Email Section
          Text(
            'Email Contact',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _sendEmail(context, 'up08-ndrf@nic.in'),
              icon: const Icon(Icons.email_outlined, size: 16, color: AppColors.primaryBlue),
              label: const Text(
                '✉️ Email: up08-ndrf@nic.in',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Attribution Tag
          Center(
            child: Text(
              'Source: National Disaster Response Force (NDRF)',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: context.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
