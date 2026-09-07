import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';
import '../../models/climate.dart';
import '../../services/climate_service.dart';
import '../../widgets/climate_chart.dart';
import '../../widgets/common_states.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  final ClimateService _climateService = ClimateService();
  List<ClimateDataPoint> _dataPoints = [];
  List<ClimateInsight> _insights = [];
  bool _isLoading = true;
  String _selectedRange = '1 Year';

  final List<String> _ranges = ['30 Days', '6 Months', '1 Year', '5 Years'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _climateService.getHistoricalTrends(range: _selectedRange);
    final insights = await _climateService.getClimateInsights();

    if (mounted) {
      setState(() {
        _dataPoints = data;
        _insights = insights;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Climate & Historical Analysis', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: LoadingCard(message: 'Analyzing multi-year climate records...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Range Selector Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time Horizon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Row(
                        children: _ranges.map((range) {
                          final isSelected = _selectedRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: ChoiceChip(
                              label: Text(range),
                              selected: isSelected,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor: context.cardBg,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : context.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedRange = range;
                                  });
                                  _loadData();
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Temperature Trend Chart
                  ClimateChartWidget(data: _dataPoints),
                  const SizedBox(height: 24),

                  // AI Climate Insights Section
                  Text('AI Climate Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
                  const SizedBox(height: 12),
                  ..._insights.map((insight) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.psychology_rounded, color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlue, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  insight.title,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.textPrimary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            insight.summary,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.isDark ? AppColors.skyBlue : AppColors.primaryBlueDark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            insight.detail,
                            style: TextStyle(fontSize: 13, color: context.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
