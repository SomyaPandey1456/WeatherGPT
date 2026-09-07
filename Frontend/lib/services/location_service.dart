import '../models/location.dart';

class LocationService {
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

  Future<LocationModel> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _savedLocations.firstWhere((l) => l.isCurrent, orElse: () => _savedLocations.first);
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
