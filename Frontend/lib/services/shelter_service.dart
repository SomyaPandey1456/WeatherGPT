import 'dart:math' as math;
import 'api_service.dart';
import '../core/config/api_config.dart';

class ShelterModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int capacity;
  final String type;
  final String status;
  final String contact;
  final double distanceKm;
  final String distanceStr;
  final bool isPrototype;

  const ShelterModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.type,
    required this.status,
    required this.contact,
    required this.distanceKm,
    required this.distanceStr,
    this.isPrototype = true,
  });

  factory ShelterModel.fromJson(Map<String, dynamic> json) {
    return ShelterModel(
      id: json['id'] ?? 'shelter',
      name: json['name'] ?? 'Emergency Shelter',
      address: json['address'] ?? 'Local Area',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,

      capacity: json['capacity'] ?? 500,
      type: json['type'] ?? 'Relief Center',
      status: json['status'] ?? 'OPEN',
      contact: json['contact'] ?? '112',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.0,
      distanceStr: json['distance_str'] ?? '1.0 km away',
      isPrototype: json['is_prototype'] ?? true,
    );
  }
}

class ShelterService {
  final ApiService _apiService = ApiService();

  Future<List<ShelterModel>> getNearbyShelters({required double latitude, required double longitude}) async {
    if (!ApiConfig.useMockData) {
      try {
        final res = await _apiService.get('/nearby-shelters', queryParams: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        });
        if (res is Map<String, dynamic> && res.containsKey('shelters')) {
          final list = res['shelters'] as List;
          return list.map((item) => ShelterModel.fromJson(item as Map<String, dynamic>)).toList();
        }
      } catch (_) {
        // Fallback to offline prototype shelters with dynamic distance calculation
      }
    }

    // Dynamic offline fallback with dynamic distance calculation
    return _getFallbackShelters(latitude, longitude);
  }

  List<ShelterModel> _getFallbackShelters(double userLat, double userLon) {
    final raw = [
      {
        'id': 'shelter_1',
        'name': 'Community Relief Center Sector Alpha',
        'address': 'Sector Alpha 1',
        'latitude': 28.4744,
        'longitude': 77.5040,
        'capacity': 500,
        'type': 'Community Center',
        'status': 'OPEN',
        'contact': '112 / 0120-2320000',
      },
      {
        'id': 'shelter_2',
        'name': 'District Indoor Sports Complex',
        'address': 'Pari Chowk',
        'latitude': 28.4670,
        'longitude': 77.5130,
        'capacity': 1200,
        'type': 'Sports Complex',
        'status': 'OPEN',
        'contact': '112 / 0120-2321111',
      },
      {
        'id': 'shelter_3',
        'name': 'Central Emergency Relief Center',
        'address': 'Connaught Place',
        'latitude': 28.6315,
        'longitude': 77.2167,
        'capacity': 1500,
        'type': 'Civic Center',
        'status': 'OPEN',
        'contact': '112 / 011-23340000',
      },
    ];

    final list = raw.map((item) {
      final lat = item['latitude'] as double;
      final lon = item['longitude'] as double;
      final dist = _approxDistanceKm(userLat, userLon, lat, lon);
      return ShelterModel(
        id: item['id'] as String,
        name: item['name'] as String,
        address: item['address'] as String,
        latitude: lat,
        longitude: lon,
        capacity: item['capacity'] as int,
        type: item['type'] as String,
        status: item['status'] as String,
        contact: item['contact'] as String,
        distanceKm: dist,
        distanceStr: '${dist.toStringAsFixed(1)} km away',
        isPrototype: true,
      );
    }).toList();

    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }

  double _approxDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        (math.cos((lat2 - lat1) * p) / 2) +
        (math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2);
    return 12742 * math.asin(math.sqrt(a));
  }
}
