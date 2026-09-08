import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/location.dart';
import 'api_service.dart';

abstract class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => message;
}

class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException([
    super.message = 'Unable to determine your current location. Please enable location services.',
  ]);
}

class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException([
    super.message = 'Unable to determine your current location. Please grant location permissions.',
  ]);
}

class LocationFetchException extends LocationException {
  const LocationFetchException([
    super.message = 'Unable to determine your current location. Please try again.',
  ]);
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiService _apiService = ApiService();

  double? _cachedLatitude;
  double? _cachedLongitude;
  String? _cachedCity;
  String? _cachedState;
  String? _cachedCountry;

  double? get currentLatitude => _cachedLatitude;
  double? get currentLongitude => _cachedLongitude;
  String? get currentCity => _cachedCity;
  bool get hasLocation => _cachedLatitude != null && _cachedLongitude != null;

  final List<LocationModel> _savedLocations = const [
    LocationModel(
      id: 'gnoida',
      name: 'Greater Noida',
      state: 'Uttar Pradesh',
      country: 'India',
      latitude: 28.4744,
      longitude: 77.5040,
      isCurrent: true,
      isSaved: true,
    ),
    LocationModel(
      id: 'delhi',
      name: 'Delhi NCR',
      state: 'Delhi',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
      isSaved: true,
    ),
    LocationModel(
      id: 'mumbai',
      name: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      latitude: 19.0760,
      longitude: 72.8777,
      isSaved: true,
    ),
    LocationModel(
      id: 'bengaluru',
      name: 'Bengaluru',
      state: 'Karnataka',
      country: 'India',
      latitude: 12.9716,
      longitude: 77.5946,
      isSaved: true,
    ),
  ];

  /// Get device latitude and longitude safely using Geolocator.
  /// Throws LocationException if service is disabled or permission denied.
  Future<({double latitude, double longitude})> getDeviceCoordinates() async {
    // 1. Check whether location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // 2. Check location permissions.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException(
        'Location permissions are permanently denied. Please enable location in system settings.',
      );
    }

    // 3. Obtain the device's current latitude and longitude.
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      _cachedLatitude = position.latitude;
      _cachedLongitude = position.longitude;

      debugPrint('📍 DEVICE GPS\nlatitude = ${position.latitude}\nlongitude = ${position.longitude}');

      return (latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      throw LocationFetchException('Unable to determine your current location. Please enable location services.');
    }
  }

  /// Get current device GPS location with dynamic reverse geocoding.
  /// Throws LocationException if location is disabled or permission is denied.
  Future<LocationModel> getCurrentLocation() async {
    final coords = await getDeviceCoordinates();

    debugPrint('🗺️ REVERSE GEOCODING\nlatitude = ${coords.latitude}\nlongitude = ${coords.longitude}');

    String city = _cachedCity ?? 'Current Location';
    String state = _cachedState ?? 'GPS Location';
    String country = _cachedCountry ?? 'India';

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${coords.latitude}&longitude=${coords.longitude}&localityLanguage=en',
        ),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          final fetchedCity = data['city']?.toString() ?? data['locality']?.toString();
          if (fetchedCity != null && fetchedCity.isNotEmpty) {
            city = fetchedCity;
            _cachedCity = fetchedCity;
          }
          final fetchedState = data['principalSubdivision']?.toString();
          if (fetchedState != null && fetchedState.isNotEmpty) {
            state = fetchedState;
            _cachedState = fetchedState;
          }
          final fetchedCountry = data['countryName']?.toString();
          if (fetchedCountry != null && fetchedCountry.isNotEmpty) {
            country = fetchedCountry;
            _cachedCountry = fetchedCountry;
          }
        }
      }
    } catch (_) {}

    return LocationModel(
      id: 'current_device',
      name: city,
      state: state,
      country: country,
      latitude: coords.latitude,
      longitude: coords.longitude,
      isCurrent: true,
      isSaved: true,
    );
  }

  /// Sync current location to backend POST /update-location.
  Future<void> syncLocationWithBackend() async {
    try {
      final coords = await getDeviceCoordinates();
      final now = DateTime.now();

      debugPrint('📤 UPDATE LOCATION\nlatitude = ${coords.latitude}\nlongitude = ${coords.longitude}\ntimestamp = ${now.toIso8601String()}');

      await _apiService.post('/update-location', {
        'lat': coords.latitude,
        'long': coords.longitude,
        'latitude': coords.latitude,
        'longitude': coords.longitude,
        'city': _cachedCity,
        'timestamp': now.toIso8601String(),
        'timezone': now.timeZoneName,
      });
    } catch (e) {
      debugPrint('Location sync notice: $e');
    }
  }

  Future<List<LocationModel>> getSavedLocations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_savedLocations);
  }

  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];
    await Future.delayed(const Duration(milliseconds: 200));

    final available = const [
      LocationModel(id: 'gnoida', name: 'Greater Noida', state: 'Uttar Pradesh', country: 'India', latitude: 28.4744, longitude: 77.5040),
      LocationModel(id: 'noida', name: 'Noida', state: 'Uttar Pradesh', country: 'India', latitude: 28.5355, longitude: 77.3910),
      LocationModel(id: 'delhi', name: 'Delhi', state: 'Delhi NCR', country: 'India', latitude: 28.6139, longitude: 77.2090),
      LocationModel(id: 'gurugram', name: 'Gurugram', state: 'Haryana', country: 'India', latitude: 28.4595, longitude: 77.0266),
      LocationModel(id: 'mumbai', name: 'Mumbai', state: 'Maharashtra', country: 'India', latitude: 19.0760, longitude: 72.8777),
      LocationModel(id: 'bengaluru', name: 'Bengaluru', state: 'Karnataka', country: 'India', latitude: 12.9716, longitude: 77.5946),
      LocationModel(id: 'kolkata', name: 'Kolkata', state: 'West Bengal', country: 'India', latitude: 22.5726, longitude: 88.3639),
      LocationModel(id: 'chennai', name: 'Chennai', state: 'Tamil Nadu', country: 'India', latitude: 13.0827, longitude: 80.2707),
      LocationModel(id: 'jaipur', name: 'Jaipur', state: 'Rajasthan', country: 'India', latitude: 26.9124, longitude: 75.7873),
      LocationModel(id: 'hyderabad', name: 'Hyderabad', state: 'Telangana', country: 'India', latitude: 17.3850, longitude: 78.4867),
    ];

    return available.where((l) => l.name.toLowerCase().contains(query.toLowerCase()) || l.state.toLowerCase().contains(query.toLowerCase())).toList();
  }
}


