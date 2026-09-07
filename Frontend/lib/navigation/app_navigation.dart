import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/theme/theme_context.dart';
import '../screens/home/home_screen.dart';
import '../screens/forecast/forecast_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/alerts/alerts_screen.dart';
import '../screens/weather/weather_now_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/climate/climate_screen.dart';
import '../screens/disaster/disaster_screen.dart';
import '../screens/location/location_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  String? _pendingChatQuery;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openChatWithQuery(String query) {
    setState(() {
      _pendingChatQuery = query;
      _currentIndex = 2; // AI Chat Tab
    });
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateTab: _onTabSelected,
        onOpenChatWithQuery: _openChatWithQuery,
        onOpenLocationScreen: () => _navigateToScreen(LocationScreen(
          onLocationSelected: (loc) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Switched weather location to ${loc.name}')),
            );
          },
        )),
        onOpenProfileScreen: () => _navigateToScreen(const SettingsScreen()),
        onOpenNotificationsScreen: () => _navigateToScreen(const NotificationsScreen()),
        onOpenMapScreen: () => _onTabSelected(3), // Navigate directly to Map tab
        onOpenClimateScreen: () => _navigateToScreen(const ClimateScreen()),
        onOpenDisasterScreen: () => _navigateToScreen(const DisasterScreen()),
        onOpenWeatherNowScreen: () => _navigateToScreen(WeatherNowScreen(
          onOpenLocation: () => _navigateToScreen(const LocationScreen()),
        )),
      ),
      const ForecastScreen(),
      ChatScreen(
        key: ValueKey(_pendingChatQuery ?? 'chat_default'),
        initialQuery: _pendingChatQuery,
      ),
      const MapScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _buildNavItem(1, Icons.calendar_today_rounded, Icons.calendar_today_outlined, 'Forecast'),
                _buildProminentChatNavItem(2),
                _buildNavItem(3, Icons.map_rounded, Icons.map_outlined, 'Map'),
                _buildNavItem(4, Icons.warning_rounded, Icons.warning_amber_rounded, 'Alerts'),
                // Settings shortcut – always visible in nav bar
                InkWell(
                  onTap: () => _navigateToScreen(const SettingsScreen()),
                  borderRadius: AppStyles.borderRadiusPill,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings_rounded,
                            color: context.textMuted, size: 24),
                        const SizedBox(height: 3),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: AppStyles.borderRadiusPill,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primaryBlue : context.textMuted,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProminentChatNavItem(int index) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.cyanAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppStyles.borderRadiusPill,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              'Chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
