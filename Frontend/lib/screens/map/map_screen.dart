import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/theme_context.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(28.4744, 77.5040); // Greater Noida

  String _selectedLayer = 'Rainfall';
  double _currentZoom = 11.0;
  bool _isFullscreen = false;
  bool _showMarkerPopup = true;
  bool _hasTileError = false;

  final List<String> _layers = [
    'Rainfall',
    'Temperature',
    'Wind Speed',
    'Cloud Cover',
    'Radar',
    'Satellite',
    'Warnings',
  ];

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1.0).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1.0).clamp(3.0, 18.0);
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _recenterMap() {
    setState(() {
      _currentZoom = 11.0;
      _mapController.move(_defaultCenter, _currentZoom);
      _showMarkerPopup = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: _isFullscreen
          ? null
          : AppBar(
              title: Text('Interactive Weather Map', style: TextStyle(color: context.textPrimary)),
              backgroundColor: context.scaffoldBg,
              iconTheme: IconThemeData(color: context.textPrimary),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isFullscreen = !_isFullscreen;
                    });
                  },
                  icon: Icon(Icons.fullscreen_rounded, color: context.textPrimary),
                  tooltip: 'Full Screen',
                ),
              ],
            ),
      body: Stack(
        children: [
          // REAL INTERACTIVE FLUTTER MAP WITH OPENSTREETMAP TILES
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: _currentZoom,
              minZoom: 3.0,
              maxZoom: 18.0,
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom;
              },
            ),
            children: [
              // Tile Layer (OpenStreetMap tiles with user-agent & fallback configuration)
              TileLayer(
                urlTemplate: ApiConfig.mapTileUrlTemplate,
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.weathergpt.app',
                maxZoom: 19,
                errorTileCallback: (tile, error, stackTrace) {
                  if (!_hasTileError && mounted) {
                    setState(() {
                      _hasTileError = true;
                    });
                  }
                },
              ),

              // Weather Overlay Layer (Simulated radar/temp overlay circles over real geographic tiles)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const LatLng(28.4744, 77.5040), // Greater Noida rain cell
                    radius: 12000,
                    useRadiusInMeter: true,
                    color: _getLayerColor(_selectedLayer).withValues(alpha: 0.35),
                    borderColor: _getLayerColor(_selectedLayer),
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const LatLng(28.6139, 77.2090), // Delhi storm cell
                    radius: 18000,
                    useRadiusInMeter: true,
                    color: _getLayerColor(_selectedLayer).withValues(alpha: 0.25),
                    borderColor: _getLayerColor(_selectedLayer),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

              // Geographic Location Markers Layer
              MarkerLayer(
                markers: [
                  Marker(
                    point: _defaultCenter,
                    width: 140,
                    height: 90,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMarkerPopup = !_showMarkerPopup;
                        });
                      },
                      child: Column(
                        children: [
                          if (_showMarkerPopup)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: context.cardBg,
                                borderRadius: AppStyles.borderRadiusMd,
                                boxShadow: AppStyles.cardShadow,
                                border: Border.all(color: AppColors.primaryBlue, width: 1.5),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Greater Noida',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const Text(
                                    '28°C • Thunderstorm',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 2),
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.criticalRed,
                            size: 36,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Offline / Network Error Fallback Banner if tiles fail to resolve
          if (_hasTileError)
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.isDark ? const Color(0xFF331C1C) : const Color(0xFFFFF2F2),
                  borderRadius: AppStyles.borderRadiusMd,
                  border: Border.all(color: AppColors.criticalRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppColors.criticalRed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Map tiles couldn\'t load due to network connectivity. Interactive grid & weather markers active.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.isDark ? const Color(0xFFFECACA) : AppColors.criticalRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasTileError = false;
                        });
                      },
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // Top Controls Overlay (Search & Layer Bar)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Location Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: AppStyles.borderRadiusPill,
                    boxShadow: AppStyles.cardShadow,
                    border: Border.all(color: context.borderBg),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: context.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Greater Noida, Uttar Pradesh, India',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _recenterMap,
                        icon: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue),
                        tooltip: 'Recenter GPS Location',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Layer Selector Horizontal Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _layers.map((layer) {
                      final isSelected = _selectedLayer == layer;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(layer),
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
                                _selectedLayer = layer;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Right Controls Overlay (Zoom & Recenter Buttons)
          Positioned(
            right: 16,
            bottom: 110,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in_map',
                  onPressed: _zoomIn,
                  backgroundColor: context.cardBg,
                  child: Icon(Icons.add_rounded, color: context.textPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out_map',
                  onPressed: _zoomOut,
                  backgroundColor: context.cardBg,
                  child: Icon(Icons.remove_rounded, color: context.textPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'recenter_map',
                  onPressed: _recenterMap,
                  backgroundColor: context.cardBg,
                  child: const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'toggle_fullscreen_map',
                  onPressed: () {
                    setState(() {
                      _isFullscreen = !_isFullscreen;
                    });
                  },
                  backgroundColor: context.cardBg,
                  child: Icon(_isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, color: context.textPrimary),
                ),
              ],
            ),
          ),

          // Bottom Legend & Scale Overlay
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: AppStyles.borderRadiusLg,
                boxShadow: AppStyles.cardShadow,
                border: Border.all(color: context.borderBg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Layer: $_selectedLayer Radar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Zoom: ${_currentZoom.round()}x',
                        style: TextStyle(fontSize: 11, color: context.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: AppStyles.borderRadiusPill,
                      gradient: _getLegendGradient(_selectedLayer),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _getLegendLabels(_selectedLayer).map((label) {
                      return Text(label, style: TextStyle(fontSize: 10, color: context.textMuted));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLayerColor(String layer) {
    if (layer == 'Temperature') return Colors.orange;
    if (layer == 'Wind Speed') return Colors.teal;
    if (layer == 'Warnings') return AppColors.criticalRed;
    return AppColors.primaryBlue;
  }

  LinearGradient _getLegendGradient(String layer) {
    if (layer == 'Temperature') {
      return const LinearGradient(colors: [Colors.blue, Colors.yellow, Colors.orange, Colors.red]);
    } else if (layer == 'Wind Speed') {
      return const LinearGradient(colors: [Colors.cyan, Colors.blue, Colors.purple]);
    }
    return const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF1E3A8A)]);
  }

  List<String> _getLegendLabels(String layer) {
    if (layer == 'Temperature') {
      return ['10°C', '20°C', '30°C', '40°C+'];
    } else if (layer == 'Wind Speed') {
      return ['0 km/h', '20 km/h', '50 km/h', '100 km/h+'];
    }
    return ['Light (0.5 mm)', 'Moderate (5 mm)', 'Heavy (15 mm)', 'Extreme (50+ mm)'];
  }
}
