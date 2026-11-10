
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:territorio_vivo/controllers/weather_controller.dart';
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

  test(
    'WeatherController carrega e disponibiliza os dados',
    () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(mockResponse),
          200,
        );
      });

      final controller = WeatherController(
        WeatherService(client: client),
      );

      await controller.loadWeather();

      expect(controller.isLoading, false);
      expect(controller.hasData, true);
      expect(controller.error, isNull);
      expect(controller.weather?.temperature, 26.4);
      expect(controller.weather?.humidity, 70);

      controller.dispose();
      client.close();
    },
  );

  test(
    'Mantem dados anteriores quando a atualizacao falha',
    () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount++;

        if (requestCount == 1) {
          return http.Response(
            jsonEncode(mockResponse),
            200,
          );
        }

        return http.Response(
          '{"error": "indisponivel"}',
          503,
        );
      });

      final controller = WeatherController(
        WeatherService(client: client),
      );

      await controller.loadWeather();

      expect(controller.weather?.temperature, 26.4);

      await controller.loadWeather();

      expect(controller.hasData, true);
      expect(controller.weather?.temperature, 26.4);
      expect(controller.error, isNotNull);
      expect(controller.isLoading, false);
      expect(requestCount, 2);

      controller.dispose();
      client.close();
    },
  );

  testWidgets(
    'Navegacao preserva os dados e evita novas consultas',
    (WidgetTester tester) async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount++;

        return http.Response(
          jsonEncode(mockResponse),
          200,
        );
      });

      await tester.pumpWidget(
        TerritorioVivoApp(
          weatherService: WeatherService(client: client),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Condições climáticas'),
        findsOneWidget,
      );

      expect(
        find.text('26.4 °C'),
        findsOneWidget,
      );

      expect(requestCount, 1);

      await tester.tap(
        find.byIcon(Icons.show_chart_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Evolução dos indicadores'),
        findsOneWidget,
      );

      expect(requestCount, 1);

      await tester.tap(
        find.byIcon(Icons.warning_amber_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Alertas em preparação'),
        findsOneWidget,
      );

      expect(requestCount, 1);

      await tester.tap(
        find.byIcon(Icons.dashboard_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('26.4 °C'),
        findsOneWidget,
      );

      await tester.tap(
        find.byTooltip('Atualizar informações'),
      );

      await tester.pumpAndSettle();

      expect(requestCount, 2);

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      client.close();
    },
  );
}
