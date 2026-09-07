import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/theme_context.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _tempUnit = 'Celsius (°C)';
  String _windUnit = 'km/h';
  bool _weatherAlerts = true;
  bool _severeAlerts = true;
  bool _dailyForecast = true;
  bool _rainNotifications = true;
  bool _voiceInput = true;
  bool _voiceOutput = true;
  bool _highContrast = false;
  bool _reducedMotion = false;
  bool _useMockData = ApiConfig.useMockData;

  final TextEditingController _apiUrlController =
      TextEditingController(text: ApiConfig.baseUrl);

  final List<String> _languages = [
    'English',
    'Hindi (हिन्दी)',
    'Bengali (বাংলা)',
    'Marathi (मराठी)',
    'Tamil (தமிழ்)',
    'Telugu (తెలుగు)',
    'Kannada (ಕನ್ನಡ)',
    'Gujarati (ગુજરાતી)',
    'Punjabi (ਪੰਜਾਬੀ)',
  ];

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Theme Section ──────────────────────────────────────────────
            Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.palette_outlined,
                            color: AppColors.primaryBlue, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'App Theme',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
                          ),
                        ),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeProvider,
                          builder: (context, mode, _) {
                            return SegmentedButton<ThemeMode>(
                              style: SegmentedButton.styleFrom(
                                backgroundColor: context.surfaceVariantBg,
                                selectedBackgroundColor: AppColors.primaryBlue,
                                selectedForegroundColor: Colors.white,
                                foregroundColor: context.textSecondary,
                                side: BorderSide(
                                    color: context.borderBg),
                                padding: EdgeInsets.zero,
                                textStyle: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              segments: const [
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_rounded, size: 16),
                                  label: Text('Light'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_rounded, size: 16),
                                  label: Text('Dark'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_rounded,
                                      size: 16),
                                  label: Text('Auto'),
                                ),
                              ],
                              selected: {mode},
                              onSelectionChanged: (newMode) {
                                themeProvider.setMode(newMode.first);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Backend Connection Configuration Section ──────────────────
            Text('Backend & API Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
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
                  SwitchListTile(
                    title: Text('Mock Data Mode',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    subtitle: Text(
                        'Use local simulated weather data when FastAPI backend is offline.', style: TextStyle(color: context.textSecondary)),
                    value: _useMockData,
                    onChanged: (val) {
                      setState(() {
                        _useMockData = val;
                        ApiConfig.useMockData = val;
                      });
                    },
                  ),
                  Divider(color: context.borderBg),
                  ListTile(
                    title: Text('FastAPI Server Base URL',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    subtitle: Text(ApiConfig.baseUrl, style: TextStyle(color: context.textSecondary)),
                    trailing: const Icon(Icons.edit_rounded,
                        color: AppColors.primaryBlue),
                    onTap: _showApiUrlDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── General Settings Section ──────────────────────────────────
            Text('General Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text('App Language',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: const SizedBox.shrink(),
                      dropdownColor: context.cardBg,
                      style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w500),
                      items: _languages
                          .map((l) =>
                              DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLanguage = val);
                      },
                    ),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  ListTile(
                    title: Text('Temperature Unit',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: _tempUnit,
                      underline: const SizedBox.shrink(),
                      dropdownColor: context.cardBg,
                      style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(
                            value: 'Celsius (°C)',
                            child: Text('Celsius (°C)')),
                        DropdownMenuItem(
                            value: 'Fahrenheit (°F)',
                            child: Text('Fahrenheit (°F)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _tempUnit = val);
                      },
                    ),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  ListTile(
                    title: Text('Wind Speed Unit',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: _windUnit,
                      underline: const SizedBox.shrink(),
                      dropdownColor: context.cardBg,
                      style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(value: 'km/h', child: Text('km/h')),
                        DropdownMenuItem(value: 'mph', child: Text('mph')),
                        DropdownMenuItem(value: 'm/s', child: Text('m/s')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _windUnit = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Notifications Section ─────────────────────────────────────
            Text('Notification Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('All Weather Push Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _weatherAlerts,
                    onChanged: (val) => setState(() => _weatherAlerts = val),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  SwitchListTile(
                    title: Text('Severe Weather Alerts',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _severeAlerts,
                    onChanged: (val) => setState(() => _severeAlerts = val),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  SwitchListTile(
                    title: Text('Daily Forecast Digest',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _dailyForecast,
                    onChanged: (val) => setState(() => _dailyForecast = val),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  SwitchListTile(
                    title: Text('Monsoon & Rain Warnings',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _rainNotifications,
                    onChanged: (val) =>
                        setState(() => _rainNotifications = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Voice Assistant Section ───────────────────────────────────
            Text('Voice Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Voice Speech Input (STT)',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _voiceInput,
                    onChanged: (val) => setState(() => _voiceInput = val),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  SwitchListTile(
                    title: Text('Text-to-Speech Audio Output (TTS)',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _voiceOutput,
                    onChanged: (val) => setState(() => _voiceOutput = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Accessibility Section ─────────────────────────────────────
            Text('Accessibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                border: Border.all(color: context.borderBg),
                boxShadow: AppStyles.softShadow,
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('High Contrast UI Mode',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _highContrast,
                    onChanged: (val) => setState(() => _highContrast = val),
                  ),
                  Divider(height: 1, color: context.borderBg),
                  SwitchListTile(
                    title: Text('Reduced Motion & Animations',
                        style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                    value: _reducedMotion,
                    onChanged: (val) => setState(() => _reducedMotion = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── About App ────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'WeatherGPT v1.0.0 (Build 1)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Indian Weather Intelligence Platform • Powered by FastAPI & Flutter',
                    style:
                        TextStyle(fontSize: 11, color: context.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showApiUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.cardBg,
          title: Text('Configure FastAPI URL', style: TextStyle(color: context.textPrimary)),
          content: TextField(
            controller: _apiUrlController,
            style: TextStyle(color: context.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. http://10.0.2.2:8000/api/v1',
              hintStyle: TextStyle(color: context.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ApiConfig.baseUrl = _apiUrlController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('FastAPI URL set to: ${ApiConfig.baseUrl}')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
