import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_context.dart';
import '../../models/forecast.dart';
import '../../services/weather_service.dart';
import '../../widgets/forecast_card.dart';
import '../../widgets/common_states.dart';

class ForecastScreen extends StatefulWidget {
  final bool isStandaloneScreen;
  final VoidCallback? onBackTap;

  const ForecastScreen({
    super.key,
    this.isStandaloneScreen = false,
    this.onBackTap,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final WeatherService _weatherService = WeatherService();
  List<HourlyForecast> _hourlyForecasts = [];
  List<DailyForecast> _dailyForecasts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hourly = await _weatherService.getHourlyForecast();
      final daily = await _weatherService.get7DayForecast();

      if (mounted) {
        setState(() {
          _hourlyForecasts = hourly;
          _dailyForecasts = daily;
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
    final canPop = Navigator.canPop(context) || widget.isStandaloneScreen;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        leading: canPop
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
                onPressed: () {
                  if (widget.onBackTap != null) {
                    widget.onBackTap!();
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                tooltip: 'Back',
              )
            : null,
        title: Text('Weather Forecast', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _fetchForecast,
            icon: Icon(Icons.refresh_rounded, color: context.textPrimary),
            tooltip: 'Refresh Forecast',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingCard(message: 'Loading hourly & 7-day forecast...'))
          : _error != null
              ? Center(child: ErrorCard(message: _error!, onRetry: _fetchForecast))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hourly Forecast Section
                      Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 136,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _hourlyForecasts.length,
                          itemBuilder: (context, index) {
                            return HourlyForecastTile(forecast: _hourlyForecasts[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 7-Day Forecast Section
                      Text(
                        '7-Day Forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dailyForecasts.length,
                        itemBuilder: (context, index) {
                          final item = _dailyForecasts[index];
                          return DailyForecastTile(
                            forecast: item,
                            onTap: () => _showDayDetailDialog(context, item),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showDayDetailDialog(BuildContext context, DailyForecast item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: context.cardBg,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.dayName} (${item.dateStr})',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.textPrimary),
                  ),
                  Text(
                    '${item.highTempC.round()}° / ${item.lowTempC.round()}°',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.summary,
                style: TextStyle(fontSize: 14, color: context.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              Divider(color: context.borderBg),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDialogMetric('Rain Chance', '${item.rainProbability}%', Icons.water_drop_rounded),
                  _buildDialogMetric('Humidity', '${item.humidityPercent}%', Icons.opacity_rounded),
                  _buildDialogMetric('Max Wind', '${item.maxWindSpeedKmH.round()} km/h', Icons.air_rounded),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primaryBlue),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
        Text(label, style: TextStyle(fontSize: 12, color: context.textMuted)),
      ],
    );
  }
}
