
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/main.dart';

void main() {
  testWidgets(
    'Exibe o painel inicial e navega entre modulos',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const TerritorioVivoApp(),
      );

      expect(
        find.text('Painel de monitoramento'),
        findsOneWidget,
      );

      // Navegar para Tendências
      await tester.tap(
        find.byIcon(Icons.show_chart_outlined),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Evolução dos indicadores'),
        findsOneWidget,
      );

      // Navegar para Alertas
      await tester.tap(
        find.byIcon(Icons.warning_amber_outlined),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Alertas em preparação'),
        findsOneWidget,
      );

      // Navegar para Registros
      await tester.tap(
        find.byIcon(Icons.assignment_outlined),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Registros em preparação'),
        findsOneWidget,
      );
    },
  );
}
