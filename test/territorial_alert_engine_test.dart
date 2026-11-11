
import 'package:flutter_test/flutter_test.dart';

import 'package:territorio_vivo/models/territorial_alert.dart';
import 'package:territorio_vivo/models/weather_data.dart';
import 'package:territorio_vivo/services/territorial_alert_engine.dart';

void main() {
  const engine = TerritorialAlertEngine();

  WeatherData makeWeather({
    List<double>? rainValues,
    List<double>? temperatures,
  }) {
    final referenceTime = DateTime(2026, 11, 11, 18);

    final rain = rainValues ??
        List<double>.filled(24, 0);

    final temps = temperatures ??
        List<double>.filled(24, 25);

    final forecast = List.generate(
      24,
      (index) => ForecastHour(
        time: referenceTime.add(
          Duration(hours: index + 1),
        ),
        temperature: temps[index],
        precipitation: rain[index],
      ),
    );

    return WeatherData(
      temperature: 25,
      humidity: 60,
      precipitation: 0,
      maxRainProbabilityToday: 50,
      referenceTime: referenceTime,
      hourlyForecast: forecast,
    );
  }

  test('Nao gera alertas com condicoes amenas', () {
    final data = makeWeather();

    final alerts = engine.evaluate(data);

    expect(alerts, isEmpty);
  });

  test('Gera atencao por chuva acumulada', () {
    final data = makeWeather(
      rainValues: List<double>.filled(24, 0.6),
    );

    final alerts = engine.evaluate(data);

    expect(alerts.length, 1);
    expect(alerts.first.id, 'precipitation');
    expect(
      alerts.first.severity,
      AlertSeverity.attention,
    );
    expect(
      alerts.first.confidence,
      AlertConfidence.low,
    );
  });

  test('Gera alerta elevado por chuva intensa', () {
    final rain = [
      12.0,
      ...List<double>.filled(23, 1.0),
    ];

    final data = makeWeather(rainValues: rain);

    final alerts = engine.evaluate(data);

    expect(alerts.length, 1);
    expect(alerts.first.id, 'precipitation');
    expect(
      alerts.first.severity,
      AlertSeverity.elevated,
    );
    expect(
      alerts.first.confidence,
      AlertConfidence.moderate,
    );
  });

  test('Gera alerta elevado por calor persistente', () {
    final temps = [
      ...List<double>.filled(4, 35),
      ...List<double>.filled(20, 27),
    ];

    final data = makeWeather(
      temperatures: temps,
    );

    final alerts = engine.evaluate(data);

    expect(alerts.length, 1);
    expect(alerts.first.id, 'heat');
    expect(
      alerts.first.severity,
      AlertSeverity.elevated,
    );
    expect(
      alerts.first.confidence,
      AlertConfidence.moderate,
    );
  });

  test('Prioriza alertas de nivel elevado', () {
    final rain = List<double>.filled(24, 0.6);

    final temps = [
      35.0,
      ...List<double>.filled(23, 25),
    ];

    final data = makeWeather(
      rainValues: rain,
      temperatures: temps,
    );

    final alerts = engine.evaluate(data);

    expect(alerts.length, 2);
    expect(alerts.first.id, 'heat');
    expect(
      alerts.first.severity,
      AlertSeverity.elevated,
    );
    expect(alerts.last.id, 'precipitation');
    expect(
      alerts.last.severity,
      AlertSeverity.attention,
    );
  });
}
