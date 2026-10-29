import '../models/weather_snapshot.dart';
import '../services/open_meteo_service.dart';
import '../../domain/models/weather_location.dart';

class WeatherRepository {
  WeatherRepository(this._service);
  final OpenMeteoService _service;
  final Map<String, WeatherSnapshot> _memoryCache = {};

  Future<List<WeatherLocation>> searchLocations(String query) => _service.searchLocations(query);

  Future<WeatherSnapshot> getWeather(WeatherLocation location, {bool forceRefresh = false}) async {
    final key = '${location.latitude.toStringAsFixed(3)},${location.longitude.toStringAsFixed(3)}';
    if (!forceRefresh && _memoryCache.containsKey(key)) return _memoryCache[key]!;
    final result = await _service.getWeather(location);
    _memoryCache[key] = result;
    return result;
  }
}
