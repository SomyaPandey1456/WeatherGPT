import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/theme_context.dart';
import '../../models/weather.dart';
import '../../services/weather_service.dart';
import '../../widgets/location_chip.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/quick_action.dart';
import '../../widgets/notification_panel.dart';
import '../../widgets/suggestion_chip.dart';
import '../../widgets/common_states.dart';

class HomeScreen extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;
  final Function(String query)? onOpenChatWithQuery;
  final VoidCallback onOpenLocationScreen;
  final VoidCallback onOpenProfileScreen;
  final VoidCallback onOpenNotificationsScreen;
  final VoidCallback onOpenMapScreen;
  final VoidCallback onOpenClimateScreen;
  final VoidCallback onOpenDisasterScreen;
  final VoidCallback onOpenWeatherNowScreen;

  const HomeScreen({
    super.key,
    this.onNavigateTab,
    this.onOpenChatWithQuery,
    required this.onOpenLocationScreen,
    required this.onOpenProfileScreen,
    required this.onOpenNotificationsScreen,
    required this.onOpenMapScreen,
    required this.onOpenClimateScreen,
    required this.onOpenDisasterScreen,
    required this.onOpenWeatherNowScreen,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _queryController = TextEditingController();

  CurrentWeather? _currentWeather;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _currentWeather = weather;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _submitQuery(String query) {
    if (query.trim().isEmpty) return;
    widget.onOpenChatWithQuery?.call(query.trim());
    _queryController.clear();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: AppStyles.borderRadiusMd,
                        ),
                        child: const Icon(
                          Icons.cloud_queue_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => NotificationPanelWidget.show(
                          context,
                          onNavigateTab: widget.onNavigateTab,
                        ),
                        icon: Icon(Icons.notifications_none_rounded, color: context.textPrimary),
                        tooltip: 'Weather Notifications',
                      ),
                      IconButton(
                        onPressed: widget.onOpenProfileScreen,
                        icon: Icon(Icons.settings_outlined, color: context.textPrimary),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Location Header Pill
              LocationChip(
                locationName: _currentWeather?.location.name ?? AppStrings.defaultLocationName,
                stateName: _currentWeather?.location.state ?? AppStrings.defaultLocationState,
                onTap: widget.onOpenLocationScreen,
              ),
              const SizedBox(height: 20),

              // AI Weather Assistant Box
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F62FE), Color(0xFF0091FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppStyles.borderRadiusXl,
                  boxShadow: AppStyles.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.askAnythingTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.askAnythingSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFE8F1FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Input Box inside AI banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppStyles.borderRadiusPill,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              onSubmitted: _submitQuery,
                              style: TextStyle(color: context.textPrimary),
                              decoration: InputDecoration(
                                hintText: AppStrings.inputPlaceholder,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_queryController.text.isNotEmpty) {
                                _submitQuery(_queryController.text);
                              } else {
                                widget.onNavigateTab?.call(2); // Open Chat tab
                              }
                            },
                            icon: const Icon(Icons.mic_none_rounded, color: AppColors.primaryBlue),
                            tooltip: 'Voice Search',
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _submitQuery(_queryController.text),
                              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                              tooltip: 'Send',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Suggested Questions Section
              Text(
                'Suggested Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppStrings.defaultSuggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SuggestionChipWidget(
                        text: suggestion,
                        onTap: () => widget.onOpenChatWithQuery?.call(suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 22),

              // Recent Queries Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Queries',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab?.call(2),
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...AppStrings.defaultRecentQueries.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => widget.onOpenChatWithQuery?.call(item['query']!),
                    borderRadius: AppStyles.borderRadiusMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: AppStyles.borderRadiusMd,
                        border: Border.all(color: context.borderBg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: context.textMuted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item['query']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item['time']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 22),

              // Current Weather Overview Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weather Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onOpenWeatherNowScreen,
                    child: const Text(
                      'Full Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _isLoading
                  ? const LoadingCard()
                  : _error != null
                      ? ErrorCard(message: _error!, onRetry: _loadData)
                      : WeatherCard(
                          weather: _currentWeather!,
                          onTap: widget.onOpenWeatherNowScreen,
                        ),
              const SizedBox(height: 24),

              // Quick Actions Grid Section
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  QuickActionCard(
                    title: AppStrings.quickWeatherNow,
                    icon: Icons.wb_sunny_rounded,
                    iconColor: AppColors.sunnyYellow,
                    backgroundColor: context.isDark ? const Color(0xFF332B1E) : AppColors.sunnyBackground,
                    onTap: widget.onOpenWeatherNowScreen,
                  ),
                  QuickActionCard(
                    title: AppStrings.quickForecast,
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.primaryBlue,
                    backgroundColor: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                    onTap: () => widget.onNavigateTab?.call(1), // Tab index 1: Forecast
                  ),
                  QuickActionCard(
                    title: AppStrings.quickMap,
                    icon: Icons.map_rounded,
                    iconColor: AppColors.tealAccent,
                    backgroundColor: context.isDark ? const Color(0xFF1E2F38) : AppColors.primaryBlueLight,
                    onTap: () => widget.onNavigateTab?.call(3), // Tab index 3: Map
                  ),
                  QuickActionCard(
                    title: AppStrings.quickAlerts,
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.severeOrange,
                    backgroundColor: context.isDark ? const Color(0xFF3B271A) : AppColors.severeOrangeBg,
                    onTap: () => widget.onNavigateTab?.call(4), // Tab index 4: Alerts (FIXED ROUTE!)
                  ),
                  QuickActionCard(
                    title: AppStrings.quickClimate,
                    icon: Icons.auto_graph_rounded,
                    iconColor: AppColors.rainyBlue,
                    backgroundColor: context.isDark ? const Color(0xFF1B2A4A) : AppColors.infoBlueBg,
                    onTap: widget.onOpenClimateScreen,
                  ),
                  QuickActionCard(
                    title: AppStrings.quickDisaster,
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.criticalRed,
                    backgroundColor: context.isDark ? const Color(0xFF3B1C1C) : AppColors.criticalRedBg,
                    onTap: widget.onOpenDisasterScreen,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
