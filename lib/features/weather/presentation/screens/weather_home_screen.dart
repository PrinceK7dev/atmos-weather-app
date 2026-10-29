import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/app.dart';
import '../../data/models/weather_snapshot.dart';
import '../../domain/models/weather_location.dart';
import '../viewmodels/weather_view_model.dart';

class WeatherHomeScreen extends ConsumerStatefulWidget {
  const WeatherHomeScreen({super.key});
  @override
  ConsumerState<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends ConsumerState<WeatherHomeScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  bool _fahrenheit = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _temp(double celsius) => _fahrenheit ? (celsius * 9 / 5) + 32 : celsius;
  String _temperature(double celsius) => '${_temp(celsius).round()}°';

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(weatherViewModelProvider);
    final location = vm.location;
    final weather = vm.weather;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF14263E), Color(0xFF08111F), Color(0xFF070B14)])),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async { if (location != null) await vm.selectLocation(location, forceRefresh: true); },
            color: const Color(0xFF7DD3FC),
            backgroundColor: const Color(0xFF17283D),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  sliver: SliverList(delegate: SliverChildListDelegate([
                    Row(children: [
                      Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF7DD3FC).withValues(alpha: .13), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .09))), child: const Icon(Icons.public_rounded, color: Color(0xFF7DD3FC))),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ATMOS', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800, fontSize: 15)), Text('GLOBAL WEATHER', style: TextStyle(letterSpacing: 1.7, color: Color(0xFF8DA5C1), fontSize: 9, fontWeight: FontWeight.w600))])),
                      IconButton(onPressed: () => setState(() => _fahrenheit = !_fahrenheit), tooltip: 'Switch temperature units', icon: Text(_fahrenheit ? '°F' : '°C', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB8D8F6)))),
                    ]),
                    const SizedBox(height: 24),
                    AnimatedContainer(duration: const Duration(milliseconds: 250), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: Column(children: [
                      TextField(controller: _searchController, textInputAction: TextInputAction.search, onTap: () => setState(() => _showSearch = true), onSubmitted: (value) => vm.search(value), onChanged: (value) { if (value.trim().length >= 2) vm.search(value); else { vm.clearSearchResults(); } }, decoration: InputDecoration(hintText: 'Search any place on Earth', hintStyle: const TextStyle(color: Color(0xFF8DA5C1)), prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7DD3FC)), suffixIcon: IconButton(onPressed: () { _searchController.clear(); setState(() => _showSearch = false); vm.search(''); }, icon: const Icon(Icons.close_rounded, color: Color(0xFF8DA5C1))), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 17))),
                      if (_showSearch && (vm.isSearching || vm.searchError != null || vm.searchResults.isNotEmpty)) ...[
                        const Divider(height: 1, color: Color(0x223A5068)),
                        if (vm.isSearching) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator(minHeight: 2)),
                        if (vm.searchError != null) Padding(padding: const EdgeInsets.all(14), child: Text(vm.searchError!, style: const TextStyle(color: Color(0xFFB9C8D9)))),
                        ...vm.searchResults.map((result) => ListTile(dense: true, leading: const Icon(Icons.location_on_outlined, color: Color(0xFF7DD3FC)), title: Text(result.name), subtitle: Text([result.admin1, result.country].whereType<String>().join(', ')), onTap: () { setState(() { _showSearch = false; _searchController.clear(); }); FocusScope.of(context).unfocus(); vm.selectLocation(result); })),
                      ],
                    ])),
                    const SizedBox(height: 28),
                    if (vm.isLoading && weather == null) const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: Color(0xFF7DD3FC))))
                    else if (vm.errorMessage != null && weather == null) _errorCard(vm.errorMessage!, () { if (location != null) vm.selectLocation(location, forceRefresh: true); })
                    else if (weather != null && location != null) ...[
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_on_rounded, size: 15, color: Color(0xFF7DD3FC)), const SizedBox(width: 5), Flexible(child: Text(location.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, letterSpacing: 2.2, fontWeight: FontWeight.w700, color: Color(0xFFC7D8EA))))]),
                      if ([location.admin1, location.country].whereType<String>().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 5), child: Text([location.admin1, location.country].whereType<String>().join(', '), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7E96B2), fontSize: 12))),
                      const SizedBox(height: 18),
                      _CurrentWeather(weather: weather, temperature: _temperature, isLoading: vm.isLoading),
                      const SizedBox(height: 26),
                      Row(children: [const Expanded(child: Text('THE NEXT 24 HOURS', style: TextStyle(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: Color(0xFF9FB6CE)))), Text('LOCAL TIME', style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.white.withValues(alpha: .45)))]),
                      const SizedBox(height: 12),
                      SizedBox(height: 124, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: weather.hourly.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (context, index) => _HourlyCard(forecast: weather.hourly[index], temperature: _temperature))),
                      const SizedBox(height: 26),
                      const Text('7-DAY OUTLOOK', style: TextStyle(fontSize: 11, letterSpacing: 1.8, fontWeight: FontWeight.w700, color: Color(0xFF9FB6CE))),
                      const SizedBox(height: 12),
                      _GlassPanel(child: Column(children: [for (var i = 0; i < weather.daily.length; i++) _DailyRow(forecast: weather.daily[i], isToday: i == 0, temperature: _temperature, isLast: i == weather.daily.length - 1)])),
                      const SizedBox(height: 20),
                      Row(children: [Expanded(child: _MetricCard(icon: Icons.water_drop_outlined, label: 'HUMIDITY', value: '${weather.humidity}%')), const SizedBox(width: 10), Expanded(child: _MetricCard(icon: Icons.air_rounded, label: 'WIND', value: '${weather.windSpeed.round()} km/h')), const SizedBox(width: 10), Expanded(child: _MetricCard(icon: Icons.thermostat_rounded, label: 'FEELS LIKE', value: _temperature(weather.apparentTemperature)))]),
                      const SizedBox(height: 22),
                      Text('Forecast data by Open-Meteo · Updated ${_formatTime(weather.updatedAt)}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF7188A3), fontSize: 10)),
                      const SizedBox(height: 4),
                      const Text('Forecasts are estimates, not guarantees.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7188A3), fontSize: 10)),
                    ],
                  ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String message, VoidCallback retry) => _GlassPanel(child: Column(children: [const Icon(Icons.cloud_off_rounded, color: Color(0xFF7DD3FC), size: 34), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton(onPressed: retry, child: const Text('Try again'))]));
  String _formatTime(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _CurrentWeather extends StatelessWidget {
  const _CurrentWeather({required this.weather, required this.temperature, required this.isLoading});
  final WeatherSnapshot weather;
  final String Function(double) temperature;
  final bool isLoading;
  @override
  Widget build(BuildContext context) => Column(children: [
    const SizedBox(height: 6),
    Container(width: 142, height: 142, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF7DD3FC).withValues(alpha: .18), const Color(0xFF7DD3FC).withValues(alpha: .015), Colors.transparent]), boxShadow: [BoxShadow(color: const Color(0xFF7DD3FC).withValues(alpha: .07), blurRadius: 55, spreadRadius: 6)]), child: Center(child: Icon(_weatherIcon(weather.weatherCode, weather.isDay), size: 76, color: const Color(0xFFD6EEFF)))),
    const SizedBox(height: 2),
    Text(temperature(weather.temperature), style: const TextStyle(fontSize: 82, height: 1, fontWeight: FontWeight.w200, letterSpacing: -4, color: Colors.white)),
    const SizedBox(height: 8),
    Text(_weatherDescription(weather.weatherCode), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFFE0ECF8))),
    const SizedBox(height: 8),
    Text('Feels like ${temperature(weather.apparentTemperature)}  ·  ${weather.precipitation.toStringAsFixed(1)} mm precipitation', style: const TextStyle(fontSize: 11, color: Color(0xFF91A8C1))),
  ]);
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.forecast, required this.temperature});
  final HourForecast forecast;
  final String Function(double) temperature;
  @override
  Widget build(BuildContext context) => Container(width: 75, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .07))), child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${forecast.time.hour.toString().padLeft(2, '0')}:00', style: const TextStyle(fontSize: 10, color: Color(0xFF9FB6CE))), Icon(_weatherIcon(forecast.weatherCode, true), size: 23, color: const Color(0xFFB8DFFF)), Text(temperature(forecast.temperature), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.water_drop, size: 10, color: Color(0xFF7DD3FC)), Text('${forecast.precipitationProbability}%', style: const TextStyle(fontSize: 9, color: Color(0xFF8BA7C4)))]) ]));
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.forecast, required this.isToday, required this.temperature, required this.isLast});
  final DayForecast forecast;
  final bool isToday;
  final bool isLast;
  final String Function(double) temperature;
  @override
  Widget build(BuildContext context) => Column(children: [Padding(padding: const EdgeInsets.symmetric(vertical: 13), child: Row(children: [SizedBox(width: 64, child: Text(isToday ? 'Today' : _weekday(forecast.date), style: TextStyle(fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: Colors.white))), Icon(_weatherIcon(forecast.weatherCode, true), size: 21, color: const Color(0xFFB8DFFF)), const SizedBox(width: 12), Expanded(child: Text(_weatherDescription(forecast.weatherCode), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF8EA5BE)))), Text(temperature(forecast.low), style: const TextStyle(fontSize: 13, color: Color(0xFF8196AD))), const SizedBox(width: 13), SizedBox(width: 34, child: Text(temperature(forecast.high), textAlign: TextAlign.end, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))) ])), if (!isLast) Divider(height: 1, color: Colors.white.withValues(alpha: .06))]);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => _GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 18, color: const Color(0xFF7DD3FC)), const SizedBox(height: 12), Text(label, style: const TextStyle(fontSize: 8, letterSpacing: .9, color: Color(0xFF8EA5BE))), const SizedBox(height: 5), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)))]));
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(22), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: child)));
}

IconData _weatherIcon(int code, bool isDay) {
  if (code == 0) return isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
  if (code == 1 || code == 2) return isDay ? Icons.wb_cloudy_rounded : Icons.cloud_rounded;
  if (code == 3) return Icons.cloud_rounded;
  if (code == 45 || code == 48) return Icons.cloud_rounded;
  if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return Icons.water_drop_rounded;
  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit_rounded;
  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_rounded;
  return Icons.cloud_queue_rounded;
}

String _weatherDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45 || code == 48) return 'Fog';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Drizzle';
  if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Rain';
  if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Snow';
  if ([95, 96, 99].contains(code)) return 'Thunderstorm';
  return 'Conditions unavailable';
}

String _weekday(DateTime date) => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
