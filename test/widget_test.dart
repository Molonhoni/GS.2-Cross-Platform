
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
import 'package:territorio_vivo/services/record_repository.dart';
import 'package:territorio_vivo/services/weather_service.dart';

// Repositório simulado para testes automatizados.
class MemoryRecordRepository implements RecordRepository {
  List<TerritorialRecord> storedRecords = [];
  bool failOnSave = false;

  @override
  Future<List<TerritorialRecord>> load() async {
    return List.of(storedRecords);
  }

  @override
  Future<void> save(
    List<TerritorialRecord> records,
  ) async {
    if (failOnSave) {
      throw StateError('Falha simulada de armazenamento.');
    }

    storedRecords = List.of(records);
  }
}

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

  // TESTE 01 - Conversão da API meteorológica.
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

  // TESTE 02 - Estado dos dados meteorológicos.
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

  // TESTE 03 - Tratamento de falha meteorológica.
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

  // TESTE 04 - Conversão dos registros para JSON.
  test('Serializa e recupera observacoes em JSON', () {
    final original = TerritorialRecord(
      id: 'record-001',
      title: 'Resíduos acumulados',
      area: 'Vila Mariana',
      description:
          'Resíduos próximos à praça da região.',
      category: RecordCategory.waste,
      createdAt: DateTime(2026, 11, 11, 19, 30),
    );

    final json = original.toJson();
    final restored = TerritorialRecord.fromJson(json);

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.area, original.area);
    expect(restored.description, original.description);
    expect(restored.category, RecordCategory.waste);
    expect(restored.createdAt, original.createdAt);
  });

  // TESTE 05 - Cadastro, recuperação e exclusão.
  test('Persiste e recupera registros entre controllers', () async {
    final repository = MemoryRecordRepository();

    final firstController = RecordController(
      repository: repository,
    );

    await firstController.loadRecords();

    expect(firstController.isReady, true);
    expect(firstController.totalRecords, 0);

    final saved = await firstController.addRecord(
      title: '  Resíduos acumulados  ',
      area: '  Vila Mariana  ',
      description:
          '  Resíduos próximos à praça da região.  ',
      category: RecordCategory.waste,
    );

    expect(saved, true);
    expect(firstController.totalRecords, 1);

    expect(
      firstController.records.first.title,
      'Resíduos acumulados',
    );

    firstController.dispose();

    // Simula uma nova execução do aplicativo.
    final secondController = RecordController(
      repository: repository,
    );

    await secondController.loadRecords();

    expect(secondController.isReady, true);
    expect(secondController.totalRecords, 1);

    expect(
      secondController.records.first.area,
      'Vila Mariana',
    );

    final recordId = secondController.records.first.id;

    final deleted = await secondController.removeRecord(
      recordId,
    );

    expect(deleted, true);
    expect(secondController.totalRecords, 0);

    secondController.dispose();

    final thirdController = RecordController(
      repository: repository,
    );

    await thirdController.loadRecords();

    expect(thirdController.totalRecords, 0);

    thirdController.dispose();
  });

  // TESTE 06 - Falha ao gravar não altera os dados.
  test('Falha de armazenamento preserva registros', () async {
    final repository = MemoryRecordRepository();

    final controller = RecordController(
      repository: repository,
    );

    await controller.loadRecords();

    final firstSaved = await controller.addRecord(
      title: 'Primeira observação',
      area: 'Santana',
      description:
          'Observação demonstrativa registrada.',
      category: RecordCategory.other,
    );

    expect(firstSaved, true);
    expect(controller.totalRecords, 1);

    repository.failOnSave = true;

    final secondSaved = await controller.addRecord(
      title: 'Segunda observação',
      area: 'Centro',
      description:
          'Segunda observação demonstrativa.',
      category: RecordCategory.other,
    );

    expect(secondSaved, false);
    expect(controller.totalRecords, 1);
    expect(repository.storedRecords.length, 1);
    expect(controller.error, isNotNull);

    controller.dispose();
  });

  // TESTE 07 - Gráficos, alertas e navegação.
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

      final repository = MemoryRecordRepository();

      await tester.pumpWidget(
        TerritorioVivoApp(
          weatherService: WeatherService(client: client),
          recordRepository: repository,
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Condições climáticas'),
        findsOneWidget,
      );

      expect(find.text('26.4 °C'), findsOneWidget);
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

      // Tendências.
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

      // Alertas.
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

      // Registros.
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

      expect(find.text('26.4 °C'), findsOneWidget);

      // Trocar de módulo não refaz a requisição.
      expect(requestCount, 1);

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      client.close();
    },
  );

  // TESTE 08 - Formulário e recuperação após reiniciar.
  testWidgets(
    'Formulario salva e recupera registro ao reiniciar',
    (WidgetTester tester) async {
      final service = createMockService();
      final repository = MemoryRecordRepository();

      await tester.pumpWidget(
        TerritorioVivoApp(
          weatherService: service,
          recordRepository: repository,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );
      await tester.pumpAndSettle();

      final saveButton = find.byKey(
        const Key('record_save_button'),
      );

      // Testa os campos obrigatórios.
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(repository.storedRecords, isEmpty);

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

      // Preenche o bairro.
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

      // Salva o registro localmente.
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(repository.storedRecords.length, 1);

      expect(
        repository.storedRecords.first.title,
        'Acúmulo na praça',
      );

      await scrollToText(
        tester,
        find.byType(RecordsScreen),
        'Acúmulo na praça',
      );

      expect(
        find.text('Acúmulo na praça'),
        findsOneWidget,
      );

      // Encerra a árvore de widgets.
      await tester.pumpWidget(
        const SizedBox.shrink(),
      );
      await tester.pumpAndSettle();

      // Simula reinicialização usando o mesmo storage.
      await tester.pumpWidget(
        TerritorioVivoApp(
          weatherService: service,
          recordRepository: repository,
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );
      await tester.pumpAndSettle();

      await scrollToText(
        tester,
        find.byType(RecordsScreen),
        'Acúmulo na praça',
      );

      // O registro precisa continuar disponível.
      expect(
        find.text('Acúmulo na praça'),
        findsOneWidget,
      );

      // Exclui o registro recuperado.
      await tester.tap(
        find.byTooltip('Excluir registro'),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.text('Excluir').last,
      );
      await tester.pumpAndSettle();

      // A exclusão também deve ser persistida.
      expect(repository.storedRecords, isEmpty);

      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      service.client?.close();
    },
  );
}
