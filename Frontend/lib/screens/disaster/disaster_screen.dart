import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});

  @override
  State<DisasterScreen> createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> {
  String _selectedCategory = 'Flood & Heavy Rain';

  final List<String> _categories = [
    'Flood & Heavy Rain',
    'Cyclone',
    'Heatwave',
    'Lightning',
    'Strong Winds',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Disaster & Safety Advisory', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.criticalRed,
                      backgroundColor: context.cardBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : context.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Active Disaster Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: AppColors.criticalRed.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_rounded, color: AppColors.criticalRed, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'DISASTER ADVISORY: NCR MONSOON INUNDATION',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.criticalRed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heavy urban inundation warning active for low-lying areas near Greater Noida expressways. Emergency response teams (NDRF) deployed.',
                    style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Safety Checklist: Do's and Don'ts
            Text('Safety Action Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  _buildCheckItem(context, true, 'Move to higher ground if located in low-lying residential sectors.'),
                  _buildCheckItem(context, true, 'Keep drinking water, emergency light, and first-aid kits ready.'),
                  _buildCheckItem(context, true, 'Turn off main electrical switches before evacuation.'),
                  Divider(height: 20, color: context.borderBg),
                  _buildCheckItem(context, false, 'Do not attempt to cross submerged roads or underpasses.'),
                  _buildCheckItem(context, false, 'Do not touch fallen electrical lines or light poles.'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Nearby Safe Locations / Shelters
            Text('Nearby Safe Relief Shelters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            _buildShelterCard(context, 'Community Center Sector Alpha 1', '1.2 km away • Capacity 500', 'Active'),
            _buildShelterCard(context, 'District Sports Complex Pari Chowk', '2.8 km away • Capacity 1200', 'Active'),
            const SizedBox(height: 22),

            // National Emergency Hotline Numbers
            Text('Emergency Helplines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Card(
              color: context.cardBg,
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                      child: const Icon(Icons.phone_rounded, size: 18, color: AppColors.primaryBlue),
                    ),
                    title: Text('NDRF National Helpline', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)),
                    trailing: const Text('011-24363260', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                      child: const Icon(Icons.local_hospital_rounded, size: 18, color: AppColors.primaryBlue),
                    ),
                    title: Text('Medical Disaster Response', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600)),
                    trailing: const Text('108', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, bool isDo, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDo ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isDo ? AppColors.successGreen : AppColors.criticalRed,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, color: context.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildShelterCard(BuildContext context, String name, String details, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: context.borderBg),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 2),
              Text(details, style: TextStyle(fontSize: 12, color: context.textMuted)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF1C3B24) : AppColors.successGreenBg,
              borderRadius: AppStyles.borderRadiusPill,
            ),
            child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
          ),
        ],
      ),
    );
  }
}
