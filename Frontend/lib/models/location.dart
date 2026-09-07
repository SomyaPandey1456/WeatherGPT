class LocationModel {
  final String id;
  final String name;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final bool isCurrent;
  final bool isSaved;

  const LocationModel({
    required this.id,
    required this.name,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.isCurrent = false,
    this.isSaved = false,
  });

  String get fullLocationString => '$name, $state, $country';
  String get shortLocationString => '$name, $state';

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isCurrent: json['is_current'] ?? false,
      isSaved: json['is_saved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'is_current': isCurrent,
      'is_saved': isSaved,
    };
  }
}
