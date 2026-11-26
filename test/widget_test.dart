
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_fit/main.dart';

void main() {
  testWidgets('PULSE FIT inicia correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseFitApp());

    expect(find.text('PULSE FIT'), findsOneWidget);
    expect(find.text('TU MOVIMIENTO.\nTUS PROPIAS MARCAS.'), findsOneWidget);
  });
}
