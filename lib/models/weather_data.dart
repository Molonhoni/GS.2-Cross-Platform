
class ForecastHour {
  final DateTime time;
  final double temperature;
  final double precipitation;

  const ForecastHour({
    required this.time,
    required this.temperature,
    required this.precipitation,
  });
}

class WeatherData {
  final double temperature;
  final int humidity;
  final double precipitation;
  final int maxRainProbabilityToday;
  final DateTime referenceTime;
  final List<ForecastHour> hourlyForecast;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.maxRainProbabilityToday,
    required this.referenceTime,
    required this.hourlyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final referenceTime =
        DateTime.parse(current['time'] as String);

    final rainProbabilities =
        daily['precipitation_probability_max']
            as List<dynamic>;

    final times = hourly['time'] as List<dynamic>;
    final temperatures =
        hourly['temperature_2m'] as List<dynamic>;
    final precipitations =
        hourly['precipitation'] as List<dynamic>;

    final forecast = <ForecastHour>[];

    for (var i = 0; i < times.length; i++) {
      if (i >= temperatures.length ||
          i >= precipitations.length) {
        break;
      }

      final temperature = temperatures[i];
      final precipitation = precipitations[i];

      if (temperature is! num || precipitation is! num) {
        continue;
      }

      final time = DateTime.parse(times[i] as String);

      if (!time.isAfter(referenceTime)) {
        continue;
      }

      forecast.add(
        ForecastHour(
          time: time,
          temperature: temperature.toDouble(),
          precipitation: precipitation.toDouble(),
        ),
      );

      if (forecast.length == 24) {
        break;
      }
    }

    if (forecast.isEmpty) {
      throw const FormatException(
        'Nenhuma previsão horária disponível.',
      );
    }

    return WeatherData(
      temperature:
          (current['temperature_2m'] as num).toDouble(),
      humidity:
          (current['relative_humidity_2m'] as num).round(),
      precipitation:
          (current['precipitation'] as num).toDouble(),
      maxRainProbabilityToday:
          (rainProbabilities.first as num).round(),
      referenceTime: referenceTime,
      hourlyForecast: forecast,
    );
  }
}
