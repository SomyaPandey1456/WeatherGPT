import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/utils/weather_utils.dart';
import '../../core/theme/theme_context.dart';
import '../../models/weather.dart';
import '../../services/weather_service.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/common_states.dart';

class WeatherNowScreen extends StatefulWidget {
  final VoidCallback onOpenLocation;

  const WeatherNowScreen({super.key, required this.onOpenLocation});

  @override
  State<WeatherNowScreen> createState() => _WeatherNowScreenState();
}

class _WeatherNowScreenState extends State<WeatherNowScreen> {
  final WeatherService _weatherService = WeatherService();
  CurrentWeather? _weather;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = await _weatherService.getCurrentWeather();
      if (mounted) {
        setState(() {
          _weather = weather;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Weather Now', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            onPressed: _fetchWeather,
            icon: Icon(Icons.refresh_rounded, color: context.textPrimary),
            tooltip: 'Refresh Weather',
          ),
          IconButton(
            onPressed: widget.onOpenLocation,
            icon: Icon(Icons.location_on_outlined, color: context.textPrimary),
            tooltip: 'Change Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingCard(message: 'Retrieving current weather metrics...'))
          : _error != null
              ? Center(child: ErrorCard(message: _error!, onRetry: _fetchWeather))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Primary Header Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.cyanAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: AppStyles.borderRadiusXl,
                          boxShadow: AppStyles.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  _weather!.location.fullLocationString,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Icon(
                              WeatherUtils.getWeatherIconData(_weather!.condition),
                              size: 72,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_weather!.temperatureC.round()}°C',
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -2,
                              ),
                            ),
                            Text(
                              _weather!.condition,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Feels like ${_weather!.feelsLikeC.round()}°C',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: AppStyles.borderRadiusPill,
                              ),
                              child: Text(
                                'Updated ${_formatTime(_weather!.lastUpdated)}',
                                style: const TextStyle(fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Weather Metrics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grid of detailed metric cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.35,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          MetricCard(
                            label: 'Humidity',
                            value: '${_weather!.humidityPercent}%',
                            icon: Icons.water_drop_rounded,
                            subtitle: 'Moisture level',
                            accentColor: AppColors.rainyBlue,
                          ),
                          MetricCard(
                            label: 'Wind Speed',
                            value: '${_weather!.windSpeedKmH.round()} km/h',
                            icon: Icons.air_rounded,
                            subtitle: 'Direction: ${_weather!.windDirection}',
                            accentColor: AppColors.tealAccent,
                          ),
                          MetricCard(
                            label: 'UV Index',
                            value: '${_weather!.uvIndex}',
                            icon: Icons.wb_sunny_rounded,
                            subtitle: WeatherUtils.getUvLevel(_weather!.uvIndex),
                            accentColor: AppColors.sunnyYellow,
                          ),
                          MetricCard(
                            label: 'Air Quality (AQI)',
                            value: '${_weather!.airQualityIndex}',
                            icon: Icons.thermostat_rounded,
                            subtitle: WeatherUtils.getAqiDescription(_weather!.airQualityIndex),
                            accentColor: WeatherUtils.getAqiColor(_weather!.airQualityIndex),
                          ),
                          MetricCard(
                            label: 'Visibility',
                            value: '${_weather!.visibilityKm} km',
                            icon: Icons.visibility_rounded,
                            subtitle: 'Clear view',
                            accentColor: AppColors.primaryBlue,
                          ),
                          MetricCard(
                            label: 'Barometric Pressure',
                            value: '${_weather!.pressureHpa} hPa',
                            icon: Icons.speed_rounded,
                            subtitle: 'Atmospheric',
                            accentColor: AppColors.skyBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Sunrise & Sunset Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: AppStyles.borderRadiusLg,
                          border: Border.all(color: context.borderBg),
                          boxShadow: AppStyles.softShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.wb_sunny_outlined, size: 28, color: AppColors.sunnyYellow),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sunrise', style: TextStyle(fontSize: 12, color: context.textMuted)),
                                    Text(
                                      _weather!.sunrise,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 30, child: VerticalDivider(color: context.borderBg)),
                            Row(
                              children: [
                                const Icon(Icons.nights_stay_outlined, size: 28, color: AppColors.stormyIndigo),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Sunset', style: TextStyle(fontSize: 12, color: context.textMuted)),
                                    Text(
                                      _weather!.sunset,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
