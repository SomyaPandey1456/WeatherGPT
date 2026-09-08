import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';
import '../../services/risk_service.dart';
import '../../services/shelter_service.dart';
import '../../services/location_service.dart';
import '../../widgets/ndrf_emergency_card.dart';

class DisasterScreen extends StatefulWidget {
  const DisasterScreen({super.key});

  @override
  State<DisasterScreen> createState() => _DisasterScreenState();
}

class _DisasterScreenState extends State<DisasterScreen> {
  final RiskService _riskService = RiskService();
  final ShelterService _shelterService = ShelterService();
  final LocationService _locationService = LocationService();

  String _selectedCategory = 'Flood & Heavy Rain';
  RiskModel _currentRisk = RiskModel.defaultLow();
  List<ShelterModel> _shelters = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Flood & Heavy Rain',
    'Heatwave',
    'Thunderstorm & Lightning',
    'Cyclone',
    'Landslide',
    'Heavy Snow',
  ];

  final Map<String, Map<String, List<String>>> _dosAndDonts = {
    'Flood & Heavy Rain': {
      'dos': [
        'Move to safer, higher ground if located in low-lying sectors.',
        'Keep drinking water, emergency flashlights, and first-aid kits accessible.',
        'Turn off main electrical switches before evacuating flooded areas.',
        'Follow official weather advisories and local authority instructions.'
      ],
      'donts': [
        'Do not drive or walk through moving floodwater or submerged underpasses.',
        'Do not touch fallen electrical lines, poles, or wet electrical switches.',
        'Do not ignore official evacuation orders or government alerts.'
      ]
    },
    'Heatwave': {
      'dos': [
        'Drink plenty of water even if not feeling thirsty.',
        'Wear lightweight, loose, light-colored cotton clothes.',
        'Stay indoors or in shade during peak heat hours (12 PM - 4 PM).'
      ],
      'donts': [
        'Do not leave children or pets inside locked parked vehicles.',
        'Do not consume alcohol, tea, or carbonated drinks that dehydrate the body.',
        'Do not engage in heavy outdoor exertion during afternoon heat.'
      ]
    },
    'Thunderstorm & Lightning': {
      'dos': [
        'Seek safe indoor shelter immediately when thunder roars.',
        'Unplug sensitive electronic appliances during severe storms.',
        'Stay inside hard-top enclosed vehicles if caught outdoors.'
      ],
      'donts': [
        'Do not stand under isolated tall trees or near metal fences.',
        'Do not use corded landline phones or take showers during lightning.',
        'Do not lie flat on open ground; crouch low on your toes if exposed.'
      ]
    },
    'Cyclone': {
      'dos': [
        'Board up glass windows and secure loose outdoor roof sheets.',
        'Keep battery-powered radios tuned to official weather updates.',
        'Store sufficient non-perishable food and clean drinking water.'
      ],
      'donts': [
        'Do not step outside during the eye of the storm when winds temporarily calm down.',
        'Do not spread unverified rumors on social media.',
        'Do not venture out to sea or near coastal shorelines.'
      ]
    },
    'Landslide': {
      'dos': [
        'Stay alert for sudden mudflows, rolling stones, or unusual tree tilting.',
        'Move quickly away from the path of a landslide or debris flow.',
        'Inform local disaster control rooms if cracks appear on hillsides.'
      ],
      'donts': [
        'Do not travel along steep mountain slopes during torrential downpours.',
        'Do not cross bridges over swollen mountain streams carrying mud debris.'
      ]
    },
    'Heavy Snow': {
      'dos': [
        'Keep warm winter clothing layered and protect extremities.',
        'Ensure proper ventilation if using indoor heating stoves or heaters.',
        'Keep vehicle exhaust pipes clear of snow accumulation.'
      ],
      'donts': [
        'Do not drive on un-sanded ice roads without tire snow chains.',
        'Do not overexert while shoveling heavy wet snow.'
      ]
    },
  };

  @override
  void initState() {
    super.initState();
    _loadDisasterData();
  }

  Future<void> _loadDisasterData() async {
    setState(() => _isLoading = true);
    try {
      final coords = await _locationService.getDeviceCoordinates();
      final risk = await _riskService.getCurrentRisk(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );
      final shelters = await _shelterService.getNearbyShelters(
        latitude: coords.latitude,
        longitude: coords.longitude,
      );

      if (mounted) {
        setState(() {
          _currentRisk = risk;
          _shelters = shelters;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNum = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNum');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open the phone app on this device.'),
              backgroundColor: AppColors.criticalRed,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the phone app on this device.'),
            backgroundColor: AppColors.criticalRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          '🆘 HELP & Emergency Contacts',
          style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w800),
        ),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDisasterData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Current Hazard Status Banner
              _buildCurrentHazardBanner(context),
              const SizedBox(height: 18),

              // 2. Emergency Assistance Header
              Text(
                'Emergency Assistance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimary),
              ),
              const SizedBox(height: 6),

              // Dedicated NDRF 8th Battalion Emergency Contact Card
              const NdrfEmergencyCard(),
              const SizedBox(height: 14),

              // National Emergency Hotline (112) & Helplines Card
              _buildEmergencyHotlinesCard(context),
              const SizedBox(height: 22),

              // 3. Nearby Refuge Shelters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Safe Relief Shelters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PROTOTYPE DATA',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Calculated dynamically from your live GPS location.',
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
              const SizedBox(height: 10),
              _buildSheltersList(context),
              const SizedBox(height: 22),

              // 4. Disaster Do's & Don'ts Checklist
              Text(
                'Disaster Action Checklist (Do\'s & Don\'ts)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
              const SizedBox(height: 10),

              // Category Selector Chips
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
                        selectedColor: AppColors.primaryBlue,
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
              const SizedBox(height: 12),
              _buildDosAndDontsCard(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentHazardBanner(BuildContext context) {
    final hasHazard = _currentRisk.level != 'LOW';
    final isCritical = _currentRisk.level == 'CRITICAL' || _currentRisk.level == 'HIGH';
    final bannerColor = hasHazard
        ? (isCritical ? AppColors.criticalRed : AppColors.warningAmber)
        : AppColors.successGreen;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDark
            ? (hasHazard ? (isCritical ? const Color(0xFF3B1C1C) : const Color(0xFF3B2F1C)) : const Color(0xFF1C3B24))
            : (hasHazard ? (isCritical ? AppColors.criticalRedBg : const Color(0xFFFFF8E6)) : AppColors.successGreenBg),
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: bannerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasHazard ? (isCritical ? Icons.campaign_rounded : Icons.warning_amber_rounded) : Icons.check_circle_rounded,
                color: bannerColor,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                hasHazard ? '⚠️ LOCAL HAZARD ALERT (${_currentRisk.level})' : '🟢 LOCAL WEATHER HAZARD STATUS',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: bannerColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentRisk.hazard,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            _currentRisk.message,
            style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.35),
          ),
          if (hasHazard) ...[
            const SizedBox(height: 8),
            Text(
              'Action: ${_currentRisk.recommendedAction}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bannerColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyHotlinesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: context.borderBg),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        children: [
          // National Emergency 112 Banner
          ListTile(
            tileColor: AppColors.criticalRed,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.phone_in_talk_rounded, color: AppColors.criticalRed, size: 20),
            ),
            title: const Text(
              'NATIONAL EMERGENCY HOTLINE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
            ),
            subtitle: const Text(
              'Police, Fire, Ambulance, Disaster',
              style: TextStyle(color: Color(0xFFFFD1D1), fontSize: 11),
            ),
            trailing: ElevatedButton(
              onPressed: () => _makePhoneCall('112'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.criticalRed,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('CALL 112', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
              child: const Icon(Icons.shield_rounded, size: 18, color: AppColors.primaryBlue),
            ),
            title: Text('NDRF National Helpline', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: OutlinedButton(
              onPressed: () => _makePhoneCall('1078'),
              child: const Text('1078', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
          ),
          Divider(height: 1, color: context.borderBg),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
              child: const Icon(Icons.location_city_rounded, size: 18, color: AppColors.primaryBlue),
            ),
            title: Text('State Disaster Management Authority (SDMA)', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: OutlinedButton(
              onPressed: () => _makePhoneCall('1070'),
              child: const Text('1070', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
          ),
          Divider(height: 1, color: context.borderBg),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
              child: const Icon(Icons.local_hospital_rounded, size: 18, color: AppColors.primaryBlue),
            ),
            title: Text('Ambulance Emergency', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
            trailing: OutlinedButton(
              onPressed: () => _makePhoneCall('102'),
              child: const Text('102', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheltersList(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_shelters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: AppStyles.borderRadiusLg,
          border: Border.all(color: context.borderBg),
        ),
        child: Text(
          'Unable to load nearby shelters right now.',
          style: TextStyle(color: context.textMuted),
        ),
      );
    }

    return Column(
      children: _shelters.map((s) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: AppStyles.borderRadiusLg,
            border: Border.all(color: context.borderBg),
            boxShadow: AppStyles.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '🏠 ${s.name}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF1C3B24) : AppColors.successGreenBg,
                      borderRadius: AppStyles.borderRadiusPill,
                    ),
                    child: Text(
                      s.status,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '📍 ${s.address} · ${s.distanceStr}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 4),
              Text(
                'Type: ${s.type} · Capacity: ${s.capacity} people',
                style: TextStyle(fontSize: 12, color: context.textMuted),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _makePhoneCall(s.contact),
                    icon: const Icon(Icons.phone_rounded, size: 14, color: AppColors.primaryBlue),
                    label: Text(s.contact, style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue)),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening map route to ${s.name}...')),
                      );
                    },
                    icon: const Icon(Icons.map_rounded, size: 14),
                    label: const Text('View on Map', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDosAndDontsCard(BuildContext context) {
    final catData = _dosAndDonts[_selectedCategory] ?? _dosAndDonts['Flood & Heavy Rain']!;
    final dos = catData['dos'] ?? [];
    final donts = catData['donts'] ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: AppStyles.borderRadiusLg,
        border: Border.all(color: context.borderBg),
        boxShadow: AppStyles.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DO', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.successGreen)),
          const SizedBox(height: 6),
          ...dos.map((item) => _buildCheckItem(context, true, item)),
          Divider(height: 24, color: context.borderBg),
          const Text('DON\'T', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.criticalRed)),
          const SizedBox(height: 6),
          ...donts.map((item) => _buildCheckItem(context, false, item)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, bool isDo, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: context.textPrimary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
