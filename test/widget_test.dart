
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:territorio_vivo/controllers/weather_controller.dart';
import 'package:territorio_vivo/main.dart';
import 'package:territorio_vivo/screens/home_screen.dart';
import 'package:territorio_vivo/screens/trends_screen.dart';
import 'package:territorio_vivo/services/weather_service.dart';

void main() {
  final hourlyTimes = List.generate(
    72,
    (index) => DateTime(2026, 11, 9)
        .add(Duration(hours: index))
        .toIso8601String()
        .substring(0, 16),
  );

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
    'hourly': {
      'time': hourlyTimes,
      'temperature_2m': List.generate(
        72,
        (index) => 20.0 + (index % 12) * 0.5,
      ),
      'precipitation': List.generate(
        72,
        (index) => index % 7 == 0 ? 1.2 : 0.0,
      ),
    },
  };

  Future<void> scrollToText(
    WidgetTester tester,
    Finder screen,
    String text, {
    double scrollDelta = 300,
  }) async {
    final scrollable = find.descendant(
      of: screen,
      matching: find.byType(Scrollable),
    ).first;

    await tester.scrollUntilVisible(
      find.text(text),
      scrollDelta,
      scrollable: scrollable,
      maxScrolls: 20,
    );

    await tester.pumpAndSettle();
  }

  test('Converte os dados e as previsoes horarias', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode(mockResponse),
        200,
      );
    });

    final service = WeatherService(client: client);
    final data = await service.fetchWeather();

    expect(data.temperature, 26.4);
    expect(data.humidity, 70);
    expect(data.maxRainProbabilityToday, 75);
    expect(data.hourlyForecast.length, 24);
    expect(data.hourlyForecast.first.time.hour, 16);

    client.close();
  });

  test('Controller carrega dados e previsoes', () async {
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

    expect(
      controller.weather?.hourlyForecast.length,
      24,
    );

    controller.dispose();
    client.close();
  });

  test('Mantem os dados quando a atualizacao falha', () async {
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

    expect(controller.hasData, true);
    expect(controller.weather?.temperature, 26.4);

    await controller.loadWeather();

    expect(controller.hasData, true);
    expect(controller.weather?.temperature, 26.4);
    expect(controller.error, isNotNull);
    expect(controller.isLoading, false);
    expect(requestCount, 2);

    controller.dispose();
    client.close();
  });

  testWidgets(
    'Exibe graficos, alertas e navega entre os modulos',
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

      // Verifica o gráfico do Dashboard.
      await scrollToText(
        tester,
        find.byType(HomeScreen),
        'Previsão de temperatura',
      );

      expect(
        find.text('Previsão de temperatura'),
        findsOneWidget,
      );

      // Navega para Tendências.
      await tester.tap(
        find.byIcon(Icons.show_chart_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Análise de tendências'),
        findsOneWidget,
      );

      await scrollToText(
        tester,
        find.byType(TrendsScreen),
        'Previsão de precipitação',
      );

      expect(
        find.text('Previsão de precipitação'),
        findsOneWidget,
      );

      expect(requestCount, 1);

      // Navega para Alertas.
      await tester.tap(
        find.byIcon(Icons.warning_amber_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Alertas preventivos'),
        findsOneWidget,
      );

      expect(
        find.text('Nenhum sinal acima dos limiares'),
        findsOneWidget,
      );

      // Navega para Registros.
      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Registros em preparação'),
        findsOneWidget,
      );

      // Retorna ao Dashboard.
      await tester.tap(
        find.byIcon(Icons.dashboard_outlined),
      );

      await tester.pumpAndSettle();

      await scrollToText(
        tester,
        find.byType(HomeScreen),
        'Condições climáticas',
        scrollDelta: -300,
      );

      expect(
        find.text('Condições climáticas'),
        findsOneWidget,
      );

      expect(
        find.text('26.4 °C'),
        findsOneWidget,
      );

      // O estado compartilhado evita novas consultas.
      expect(requestCount, 1);

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      client.close();
    },
  );
}
