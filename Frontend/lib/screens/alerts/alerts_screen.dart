import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/theme_context.dart';
import '../../models/alert.dart';
import '../../services/alert_service.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/common_states.dart';
import 'alert_details_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();
  List<WeatherAlert> _alerts = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final alerts = await _alertService.getActiveAlerts();
      if (mounted) {
        setState(() {
          _alerts = alerts;
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

  List<WeatherAlert> get _filteredAlerts {
    if (_selectedFilter == 'Critical') {
      return _alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    } else if (_selectedFilter == 'Rain') {
      return _alerts.where((a) => a.alertType.toLowerCase().contains('rain')).toList();
    }
    return _alerts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Weather Alerts', style: TextStyle(color: context.textPrimary)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
        actions: [
          IconButton(
            onPressed: _fetchAlerts,
            icon: Icon(Icons.refresh_rounded, color: context.textPrimary),
            tooltip: 'Refresh Alerts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            color: context.cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Critical', 'Rain', 'Thunderstorm', 'Heatwave'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: context.cardBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : context.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Divider(height: 1, color: context.borderBg),

          Expanded(
            child: _isLoading
                ? const Center(child: LoadingCard(message: 'Scanning official weather alerts...'))
                : _error != null
                    ? Center(child: ErrorCard(message: _error!, onRetry: _fetchAlerts))
                    : _filteredAlerts.isEmpty
                        ? const Center(
                            child: EmptyStateCard(
                              title: 'No weather alerts',
                              message: 'There are currently no active weather alerts for your selected filter.',
                              icon: Icons.shield_outlined,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAlerts.length,
                            itemBuilder: (context, index) {
                              final alert = _filteredAlerts[index];
                              return AlertCard(
                                alert: alert,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlertDetailsScreen(alert: alert),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
