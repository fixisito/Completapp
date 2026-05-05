import 'package:flutter_test/flutter_test.dart';
import 'package:completapp/main.dart';

void main() {
  testWidgets('CompletApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CompletApp());
    expect(find.text('CompletApp'), findsOneWidget);
  });
}
