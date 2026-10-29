class HourForecast {
  const HourForecast({required this.time, required this.temperature, required this.precipitationProbability, required this.weatherCode});
  final DateTime time;
  final double temperature;
  final int precipitationProbability;
  final int weatherCode;
}

class DayForecast {
  const DayForecast({required this.date, required this.high, required this.low, required this.weatherCode});
  final DateTime date;
  final double high;
  final double low;
  final int weatherCode;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.precipitation,
    required this.weatherCode,
    required this.isDay,
    required this.updatedAt,
    required this.timezone,
    required this.hourly,
    required this.daily,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double precipitation;
  final int weatherCode;
  final bool isDay;
  final DateTime updatedAt;
  final String timezone;
  final List<HourForecast> hourly;
  final List<DayForecast> daily;

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;
    final hourlyTimes = (hourlyJson['time'] as List).cast<String>();
    final hourlyTemps = (hourlyJson['temperature_2m'] as List).cast<num>();
    final hourlyRain = (hourlyJson['precipitation_probability'] as List).cast<num>();
    final hourlyCodes = (hourlyJson['weather_code'] as List).cast<num>();
    final now = DateTime.parse(current['time'] as String);
    final startIndex = hourlyTimes.indexWhere((time) => !DateTime.parse(time).isBefore(now));
    final safeStart = startIndex < 0 ? 0 : startIndex;
    final hours = <HourForecast>[];
    for (var i = safeStart; i < hourlyTimes.length && hours.length < 24; i++) {
      hours.add(HourForecast(time: DateTime.parse(hourlyTimes[i]), temperature: hourlyTemps[i].toDouble(), precipitationProbability: hourlyRain[i].toInt(), weatherCode: hourlyCodes[i].toInt()));
    }
    final dailyTimes = (dailyJson['time'] as List).cast<String>();
    final highs = (dailyJson['temperature_2m_max'] as List).cast<num>();
    final lows = (dailyJson['temperature_2m_min'] as List).cast<num>();
    final codes = (dailyJson['weather_code'] as List).cast<num>();
    final days = <DayForecast>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      days.add(DayForecast(date: DateTime.parse(dailyTimes[i]), high: highs[i].toDouble(), low: lows[i].toDouble(), weatherCode: codes[i].toInt()));
    }
    return WeatherSnapshot(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      isDay: (current['is_day'] as num).toInt() == 1,
      updatedAt: now,
      timezone: json['timezone'] as String? ?? 'auto',
      hourly: hours,
      daily: days,
    );
  }
}
