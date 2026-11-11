
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:territorio_vivo/controllers/record_controller.dart';
import 'package:territorio_vivo/models/territorial_record.dart';
import 'package:territorio_vivo/screens/privacy_screen.dart';
import 'package:territorio_vivo/services/record_repository.dart';

class TestRecordRepository implements RecordRepository {
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
      throw StateError(
        'Falha simulada no armazenamento.',
      );
    }

    storedRecords = List.of(records);
  }
}

void main() {
  Future<void> createExampleRecord(
    RecordController controller,
  ) async {
    await controller.addRecord(
      title: 'Resíduos acumulados',
      area: 'Vila Mariana',
      description:
          'Acúmulo de resíduos próximo à praça.',
      category: RecordCategory.waste,
    );
  }

  // TESTE 01 - Exclusão de todos os registros.
  test(
    'Exclui todos os registros do armazenamento',
    () async {
      final repository = TestRecordRepository();

      final controller = RecordController(
        repository: repository,
      );

      await controller.loadRecords();
      await createExampleRecord(controller);

      expect(controller.totalRecords, 1);
      expect(repository.storedRecords.length, 1);

      final success = await controller.clearRecords();

      expect(success, true);
      expect(controller.totalRecords, 0);
      expect(repository.storedRecords, isEmpty);

      controller.dispose();
    },
  );

  // TESTE 02 - Falha durante a exclusão.
  test(
    'Preserva os registros quando a exclusao falha',
    () async {
      final repository = TestRecordRepository();

      final controller = RecordController(
        repository: repository,
      );

      await controller.loadRecords();
      await createExampleRecord(controller);

      repository.failOnSave = true;

      final success = await controller.clearRecords();

      expect(success, false);
      expect(controller.totalRecords, 1);
      expect(repository.storedRecords.length, 1);
      expect(controller.error, isNotNull);

      controller.dispose();
    },
  );

  // TESTE 03 - Confirmação antes de excluir registros.
  testWidgets(
    'Solicita confirmacao antes de apagar registros',
    (WidgetTester tester) async {
      final repository = TestRecordRepository();

      final controller = RecordController(
        repository: repository,
      );

      await controller.loadRecords();
      await createExampleRecord(controller);

      // Confirma que existe um registro armazenado.
      expect(controller.totalRecords, 1);

      await tester.pumpWidget(
        MaterialApp(
          home: PrivacyScreen(
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifica a abertura da página.
      expect(
        find.text('Seus dados, suas escolhas'),
        findsOneWidget,
      );

      // Localiza a área de gerenciamento dos dados.
      final deleteButton = find.byKey(
        const Key('privacy_delete_all_button'),
      );

      // CORREÇÃO:
      // Rola a página até o botão de exclusão.
      // Isso permite construir os elementos da
      // ListView que estão fora da área visível.
      await tester.scrollUntilVisible(
        deleteButton,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 40,
      );

      await tester.pumpAndSettle();

      // Agora a seção está construída e visível.
      expect(
        find.text('1 registro local'),
        findsOneWidget,
      );

      expect(deleteButton, findsOneWidget);

      // PRIMEIRA TENTATIVA:
      // Abre a confirmação e cancela.
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Excluir todos os registros?'),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Cancelar'),
      );

      await tester.pumpAndSettle();

      // Cancelar não pode remover os registros.
      expect(controller.totalRecords, 1);
      expect(repository.storedRecords.length, 1);

      // SEGUNDA TENTATIVA:
      // Abre a confirmação e exclui definitivamente.
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Excluir todos os registros?'),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Excluir definitivamente'),
      );

      await tester.pumpAndSettle();

      // Confirma a exclusão no controlador.
      expect(controller.totalRecords, 0);

      // Confirma a exclusão no armazenamento.
      expect(repository.storedRecords, isEmpty);

      // Verifica a atualização da interface.
      expect(
        find.text('0 registros locais'),
        findsOneWidget,
      );

      // Encerra a árvore de widgets.
      await tester.pumpWidget(
        const SizedBox.shrink(),
      );

      await tester.pumpAndSettle();

      controller.dispose();
    },
  );
}
