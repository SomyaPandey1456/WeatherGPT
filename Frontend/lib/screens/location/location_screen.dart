import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/theme/theme_context.dart';
import '../../models/location.dart';
import '../../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  final Function(LocationModel location)? onLocationSelected;

  const LocationScreen({super.key, this.onLocationSelected});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  List<LocationModel> _savedLocations = [];
  List<LocationModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locations = await _locationService.getSavedLocations();
    if (mounted) {
      setState(() {
        _savedLocations = locations;
      });
    }
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _locationService.searchLocations(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text('Location Management', style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700)),
        backgroundColor: context.scaffoldBg,
        iconTheme: IconThemeData(color: context.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Location Detection Button
            ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Detecting device GPS location...')),
                );
                try {
                  final loc = await _locationService.getCurrentLocation();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('GPS Location detected: ${loc.name}, ${loc.state}')),
                    );
                    widget.onLocationSelected?.call(loc);
                    navigator.pop();
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },

              icon: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue),
              label: Text(
                'Use Current GPS Location',
                style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.cardBg,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.borderRadiusPill),
                elevation: 0,
                side: BorderSide(color: context.borderBg),
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search city or state in India...',
                hintStyle: TextStyle(color: context.textMuted),
                prefixIcon: Icon(Icons.search_rounded, color: context.textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: context.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Search Results List
            if (_isSearching) ...[
              Text('Search Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 10),
              _searchResults.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No matching locations found.', style: TextStyle(color: context.textMuted)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_city_rounded, color: AppColors.primaryBlue),
                          title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                          subtitle: Text('${item.state}, ${item.country}', style: TextStyle(color: context.textSecondary)),
                          onTap: () {
                            widget.onLocationSelected?.call(item);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ] else ...[
              // Saved Locations
              Text('Saved Locations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.textPrimary)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedLocations.length,
                itemBuilder: (context, index) {
                  final item = _savedLocations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: AppStyles.borderRadiusLg,
                      border: Border.all(color: context.borderBg),
                      boxShadow: AppStyles.softShadow,
                    ),
                    child: ListTile(
                      leading: Icon(
                        item.isCurrent ? Icons.location_on_rounded : Icons.place_outlined,
                        color: item.isCurrent ? AppColors.primaryBlue : context.textMuted,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: item.isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      subtitle: Text('${item.state}, ${item.country}', style: TextStyle(color: context.textSecondary)),
                      trailing: item.isCurrent
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.isDark ? const Color(0xFF1E2B45) : AppColors.primaryBlueLight,
                                borderRadius: AppStyles.borderRadiusPill,
                              ),
                              child: const Text('Current', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                            )
                          : Icon(Icons.chevron_right_rounded, color: context.textMuted),
                      onTap: () {
                        widget.onLocationSelected?.call(item);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
