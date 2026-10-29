import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_snapshot.dart';
import '../../domain/models/weather_location.dart';

class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<WeatherLocation>> searchLocations(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '8',
      'language': 'en',
      'format': 'json',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) throw Exception('Location search failed (${response.statusCode}).');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (body['results'] as List<dynamic>? ?? []);
    return results.map((item) => WeatherLocation.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<WeatherSnapshot> getWeather(WeatherLocation location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset',
      'timezone': 'auto',
      'forecast_days': '7',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw Exception('Weather service failed (${response.statusCode}).');
    return WeatherSnapshot.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
