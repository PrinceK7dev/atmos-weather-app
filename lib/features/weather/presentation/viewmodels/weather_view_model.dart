import 'package:flutter/foundation.dart';
import '../../data/models/weather_snapshot.dart';
import '../../data/repositories/weather_repository.dart';
import '../../domain/models/weather_location.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel(this._repository) {
    selectLocation(const WeatherLocation(name: 'Niagara Falls', latitude: 43.0896, longitude: -79.0849, country: 'Canada'));
  }
  final WeatherRepository _repository;

  WeatherLocation? location;
  WeatherSnapshot? weather;
  List<WeatherLocation> searchResults = [];
  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  String? searchError;

  Future<void> selectLocation(WeatherLocation value, {bool forceRefresh = false}) async {
    location = value;
    isLoading = true;
    errorMessage = null;
    searchResults = [];
    notifyListeners();
    try {
      weather = await _repository.getWeather(value, forceRefresh: forceRefresh);
    } catch (_) {
      errorMessage = 'Could not load weather. Check your connection and try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    searchResults = [];
    searchError = null;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().length < 2) {
      searchResults = [];
      searchError = null;
      notifyListeners();
      return;
    }
    isSearching = true;
    searchError = null;
    notifyListeners();
    try {
      searchResults = await _repository.searchLocations(query.trim());
      if (searchResults.isEmpty) searchError = 'No matching places found. Try a city or region name.';
    } catch (_) {
      searchError = 'Search failed. Please try again.';
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
}
