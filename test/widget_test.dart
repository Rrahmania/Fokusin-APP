import 'package:flutter_test/flutter_test.dart';
import 'package:fokusinaja/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FokusinApp());
    expect(find.byType(FokusinApp), findsOneWidget);
  });
}