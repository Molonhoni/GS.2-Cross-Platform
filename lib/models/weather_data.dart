
class WeatherData {
  final double temperature;
  final int humidity;
  final double precipitation;
  final int maxRainProbabilityToday;
  final DateTime referenceTime;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.maxRainProbabilityToday,
    required this.referenceTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final rainProbabilities =
        daily['precipitation_probability_max'] as List<dynamic>;

    return WeatherData(
      temperature:
          (current['temperature_2m'] as num).toDouble(),
      humidity:
          (current['relative_humidity_2m'] as num).round(),
      precipitation:
          (current['precipitation'] as num).toDouble(),
      maxRainProbabilityToday:
          (rainProbabilities.first as num).round(),
      referenceTime:
          DateTime.parse(current['time'] as String),
    );
  }
}
