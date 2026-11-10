
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:territorio_vivo/main.dart';
import 'package:territorio_vivo/services/weather_service.dart';

void main() {
  final mockResponse = {
    'current': {
      'time': '2026-11-09T15:15',
      'temperature_2m': 26.4,
      'relative_humidity_2m': 70,
      'precipitation': 0.0,
    },
    'daily': {
      'precipitation_probability_max': [75, 45, 30],
    },
  };

  WeatherService createMockService() {
    return WeatherService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode(mockResponse),
          200,
          headers: {
            'content-type': 'application/json',
          },
        );
      }),
    );
  }

  test('Converte os dados meteorológicos da API', () async {
    final service = createMockService();
    final data = await service.fetchWeather();

    expect(data.temperature, 26.4);
    expect(data.humidity, 70);
    expect(data.precipitation, 0.0);
    expect(data.maxRainProbabilityToday, 75);
  });

  testWidgets('Exibe clima e navega entre os modulos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TerritorioVivoApp(
        weatherService: createMockService(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Território Vivo'), findsOneWidget);
    expect(find.text('Condições climáticas'), findsOneWidget);
    expect(find.text('26.4 °C'), findsOneWidget);

    await tester.tap(
      find.byIcon(Icons.show_chart_outlined),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Evolução dos indicadores'),
      findsOneWidget,
    );

    await tester.tap(
      find.byIcon(Icons.warning_amber_outlined),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Alertas em preparação'),
      findsOneWidget,
    );

    await tester.tap(
      find.byIcon(Icons.assignment_outlined),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Registros em preparação'),
      findsOneWidget,
    );
  });
}
