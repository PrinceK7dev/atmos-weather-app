class WeatherLocation {
  const WeatherLocation({required this.name, required this.latitude, required this.longitude, this.country, this.admin1});

  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;

  factory WeatherLocation.fromJson(Map<String, dynamic> json) => WeatherLocation(
        name: json['name'] as String? ?? 'Unknown location',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        country: json['country'] as String?,
        admin1: json['admin1'] as String?,
      );

  String get displayName => [name, admin1, country].where((part) => part != null && part.trim().isNotEmpty).join(', ');
}
