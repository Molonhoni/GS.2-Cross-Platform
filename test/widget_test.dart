
import 'package:flutter_test/flutter_test.dart';
import 'package:territorio_vivo/main.dart';

void main() {
  testWidgets('Exibe a tela inicial do Território Vivo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TerritorioVivoApp());

    expect(find.text('Território Vivo'), findsOneWidget);
    expect(find.text('Alertas preventivos'), findsOneWidget);
  });
}
