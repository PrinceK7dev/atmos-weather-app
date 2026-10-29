import 'package:flutter/material.dart';
import '../features/weather/data/repositories/weather_repository.dart';
import '../features/weather/data/services/open_meteo_service.dart';
import '../features/weather/presentation/screens/weather_home_screen.dart';
import '../features/weather/presentation/viewmodels/weather_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final weatherServiceProvider = Provider((ref) => OpenMeteoService());
final weatherRepositoryProvider = Provider((ref) => WeatherRepository(ref.watch(weatherServiceProvider)));
final weatherViewModelProvider = ChangeNotifierProvider((ref) => WeatherViewModel(ref.watch(weatherRepositoryProvider)));

class AtmosApp extends StatelessWidget {
  const AtmosApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF08111F);
    return MaterialApp(
      title: 'Atmos Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7DD3FC), brightness: Brightness.dark),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF7DD3FC))),
        ),
      ),
      home: const WeatherHomeScreen(),
    );
  }
}
