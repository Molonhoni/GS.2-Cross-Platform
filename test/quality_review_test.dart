
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:territorio_vivo/controllers/record_controller.dart';
import 'package:territorio_vivo/main.dart';
import 'package:territorio_vivo/models/territorial_record.dart';
import 'package:territorio_vivo/models/weather_data.dart';
import 'package:territorio_vivo/services/record_repository.dart';
import 'package:territorio_vivo/services/weather_service.dart';
import 'package:territorio_vivo/widgets/accessible_forecast_chart.dart';

class _TestRecordRepository implements RecordRepository {
  final bool failOnLoad;

  final List<TerritorialRecord> _records = [];

  _TestRecordRepository({
    this.failOnLoad = false,
  });

  @override
  Future<List<TerritorialRecord>> load() async {
    if (failOnLoad) {
      throw StateError('Falha simulada de leitura.');
    }

    return List<TerritorialRecord>.of(_records);
  }

  @override
  Future<void> save(
    List<TerritorialRecord> records,
  ) async {
    _records
      ..clear()
      ..addAll(records);
  }
}

Map<String, dynamic> _createWeatherResponse() {
  final firstHour = DateTime(2026, 11, 11);

  final times = List.generate(
    72,
    (index) => firstHour
        .add(Duration(hours: index))
        .toIso8601String()
        .substring(0, 16),
  );

  return {
    'current': {
      'time': '2026-11-11T15:15',
      'temperature_2m': 24.5,
      'relative_humidity_2m': 65,
      'precipitation': 0.0,
    },
    'daily': {
      'precipitation_probability_max': [
        40,
        50,
        35,
      ],
    },
    'hourly': {
      'time': times,
      'temperature_2m': List.generate(
        72,
        (index) => 19.0 + (index % 12) * 0.4,
      ),
      'precipitation': List.generate(
        72,
        (index) => index % 9 == 0 ? 0.5 : 0.0,
      ),
    },
  };
}

void main() {
  // TESTE 01 - API indisponível.
  test(
    'API indisponivel retorna erro controlado',
    () async {
      final client = MockClient((request) async {
        return http.Response(
          'Serviço indisponível',
          503,
        );
      });

      final service = WeatherService(client: client);

      await expectLater(
        service.fetchWeather(),
        throwsA(isA<WeatherException>()),
      );

      client.close();
    },
  );

  // TESTE 02 - Resposta inválida da API.
  test(
    'Resposta meteorologica invalida e tratada',
    () async {
      final client = MockClient((request) async {
        return http.Response(
          '{"current": {}}',
          200,
        );
      });

      final service = WeatherService(client: client);

      await expectLater(
        service.fetchWeather(),
        throwsA(isA<WeatherException>()),
      );

      client.close();
    },
  );

  // TESTE 03 - Falha ao recuperar registros.
  test(
    'Falha de leitura impede cadastro inseguro',
    () async {
      final repository = _TestRecordRepository(
        failOnLoad: true,
      );

      final controller = RecordController(
        repository: repository,
      );

      await controller.loadRecords();

      expect(controller.isReady, false);
      expect(controller.isLoading, false);
      expect(controller.error, isNotNull);

      final saved = await controller.addRecord(
        title: 'Observação de teste',
        area: 'Centro',
        description:
            'Registro demonstrativo para validação.',
        category: RecordCategory.other,
      );

      expect(saved, false);
      expect(controller.totalRecords, 0);

      controller.dispose();
    },
  );

  // TESTE 04 - Categoria desconhecida.
  test(
    'Categoria desconhecida recebe valor seguro',
    () {
      final record = TerritorialRecord.fromJson({
        'id': 'registro-qualidade',
        'title': 'Observação de teste',
        'area': 'Centro',
        'description':
            'Descrição de teste da observação.',
        'category': 'categoria_desconhecida',
        'createdAt': '2026-11-11T15:00:00',
      });

      expect(
        record.category,
        RecordCategory.other,
      );

      expect(
        record.title,
        'Observação de teste',
      );
    },
  );

  // TESTE 05 - Acessibilidade dos gráficos.
  testWidgets(
    'Grafico apresenta resumo acessivel',
    (WidgetTester tester) async {
      final semanticsHandle = tester.ensureSemantics();

      try {
        final firstHour = DateTime(
          2026,
          11,
          11,
          16,
        );

        final forecast = List.generate(
          24,
          (index) => ForecastHour(
            time: firstHour.add(
              Duration(hours: index),
            ),
            temperature: 20.0 + index * 0.2,
            precipitation: 0.0,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AccessibleForecastChart(
                  forecast: forecast,
                  type: ForecastChartType.temperature,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Previsão de temperatura'),
          findsOneWidget,
        );

        expect(
          find.textContaining(
            'Resumo: Temperatura prevista',
          ),
          findsOneWidget,
        );

        expect(
          find.bySemanticsLabel(
            RegExp(r'Temperatura prevista:'),
          ),
          findsWidgets,
        );

        expect(tester.takeException(), isNull);
      } finally {
        // Corrige o erro de SemanticsHandle ativo.
        // É necessário liberar antes de encerrar
        // o teste automatizado.
        semanticsHandle.dispose();
      }
    },
  );

  // TESTES 06 E 07 - Responsividade.
  for (final screenSize in const [
    Size(390, 844),
    Size(960, 720),
  ]) {
    testWidgets(
      'Navegacao sem erros em ${screenSize.width.toInt()} px',
      (WidgetTester tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = screenSize;

        addTearDown(tester.view.reset);

        final client = MockClient((request) async {
          return http.Response(
            jsonEncode(_createWeatherResponse()),
            200,
          );
        });

        final repository = _TestRecordRepository();

        await tester.pumpWidget(
          TerritorioVivoApp(
            weatherService: WeatherService(
              client: client,
            ),
            recordRepository: repository,
          ),
        );

        await tester.pumpAndSettle();

        // Verifica a tela inicial.
        expect(
          find.text('Território Vivo'),
          findsOneWidget,
        );

        expect(
          find.text('Condições climáticas'),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);

        // Abre Tendências.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byIcon(
              Icons.show_chart_outlined,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Análise de tendências'),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);

        // Abre Alertas.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byIcon(
              Icons.warning_amber_outlined,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Alertas preventivos'),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);

        // Abre Registros.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byIcon(
              Icons.assignment_outlined,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Registros de campo'),
          findsOneWidget,
        );

        expect(tester.takeException(), isNull);

        // Retorna ao Dashboard.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.byIcon(
              Icons.dashboard_outlined,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Abre a página de privacidade.
        await tester.tap(
          find.byTooltip(
            'Privacidade e acessibilidade',
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Seus dados, suas escolhas'),
          findsOneWidget,
        );

        // Nenhuma exceção de layout deve ocorrer.
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(
          const SizedBox.shrink(),
        );

        await tester.pumpAndSettle();

        client.close();
      },
    );
  }
}
