
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:territorio_vivo/controllers/record_controller.dart';
import 'package:territorio_vivo/controllers/weather_controller.dart';
import 'package:territorio_vivo/main.dart';
import 'package:territorio_vivo/models/territorial_record.dart';
import 'package:territorio_vivo/screens/home_screen.dart';
import 'package:territorio_vivo/screens/records_screen.dart';
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

  WeatherService createMockService() {
    return WeatherService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode(mockResponse),
          200,
        );
      }),
    );
  }

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
      maxScrolls: 30,
    );

    await tester.pumpAndSettle();
  }

  test('Converte os dados e as previsoes horarias', () async {
    final service = createMockService();
    final data = await service.fetchWeather();

    expect(data.temperature, 26.4);
    expect(data.humidity, 70);
    expect(data.maxRainProbabilityToday, 75);
    expect(data.hourlyForecast.length, 24);
    expect(data.hourlyForecast.first.time.hour, 16);

    service.client?.close();
  });

  test('Controller carrega dados e previsoes', () async {
    final service = createMockService();
    final controller = WeatherController(service);

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
    service.client?.close();
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

    await controller.loadWeather();

    expect(controller.hasData, true);
    expect(controller.weather?.temperature, 26.4);
    expect(controller.error, isNotNull);
    expect(controller.isLoading, false);
    expect(requestCount, 2);

    controller.dispose();
    client.close();
  });

  test(
    'RecordController cadastra e remove observacoes',
    () {
      final controller = RecordController();

      expect(controller.totalRecords, 0);

      controller.addRecord(
        title: '  Resíduos acumulados  ',
        area: '  Vila Mariana  ',
        description:
            '  Acúmulo de resíduos próximo à praça.  ',
        category: RecordCategory.waste,
      );

      expect(controller.totalRecords, 1);
      expect(
        controller.records.first.title,
        'Resíduos acumulados',
      );
      expect(
        controller.records.first.area,
        'Vila Mariana',
      );
      expect(
        controller.records.first.category,
        RecordCategory.waste,
      );

      final recordId = controller.records.first.id;

      expect(controller.removeRecord(recordId), true);
      expect(controller.totalRecords, 0);
      expect(controller.removeRecord(recordId), false);

      controller.dispose();
    },
  );

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

      await scrollToText(
        tester,
        find.byType(HomeScreen),
        'Previsão de temperatura',
      );

      expect(
        find.text('Previsão de temperatura'),
        findsOneWidget,
      );

      // Navegação para Tendências.
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

      // Navegação para Alertas.
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

      // Navegação para Registros.
      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Registros de campo'),
        findsOneWidget,
      );

      expect(
        find.text('Nova observação'),
        findsOneWidget,
      );

      // Retorno ao Dashboard.
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
        find.text('26.4 °C'),
        findsOneWidget,
      );

      // A navegação não deve refazer a consulta.
      expect(requestCount, 1);

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      client.close();
    },
  );

  testWidgets(
    'Formulario valida e cadastra observacoes',
    (WidgetTester tester) async {
      final service = createMockService();

      await tester.pumpWidget(
        TerritorioVivoApp(weatherService: service),
      );

      await tester.pumpAndSettle();

      // Abre a tela de registros.
      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );

      await tester.pumpAndSettle();

      final saveButton = find.byKey(
        const Key('record_save_button'),
      );

      // Tenta salvar sem preencher os campos.
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Observação registrada com sucesso.'),
        findsNothing,
      );

      // Preenche o título.
      final titleField = find.byKey(
        const Key('record_title_field'),
      );

      await tester.ensureVisible(titleField);
      await tester.enterText(
        titleField,
        'Acúmulo na praça',
      );

      // Seleciona a categoria.
      final categoryField = find.byKey(
        const Key('record_category_field'),
      );

      await tester.ensureVisible(categoryField);
      await tester.pumpAndSettle();
      await tester.tap(categoryField);
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Resíduos e limpeza').last,
      );

      await tester.pumpAndSettle();

      // Preenche a região.
      final areaField = find.byKey(
        const Key('record_area_field'),
      );

      await tester.ensureVisible(areaField);
      await tester.enterText(
        areaField,
        'Vila Mariana',
      );

      // Preenche a descrição.
      final descriptionField = find.byKey(
        const Key('record_description_field'),
      );

      await tester.ensureVisible(descriptionField);
      await tester.enterText(
        descriptionField,
        'Resíduos acumulados próximos à praça.',
      );

      // Salva a observação.
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Localiza o registro na lista.
      await scrollToText(
        tester,
        find.byType(RecordsScreen),
        'Acúmulo na praça',
      );

      expect(
        find.text('Acúmulo na praça'),
        findsOneWidget,
      );

      expect(
        find.text('Registros cadastrados (1)'),
        findsOneWidget,
      );

      // Verifica que o registro permanece ao
      // trocar de tela e retornar.
      await tester.tap(
        find.byIcon(Icons.show_chart_outlined),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Acúmulo na praça'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      service.client?.close();
    },
  );
}
