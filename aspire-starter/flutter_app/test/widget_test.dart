import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const HospiCareApp());
    expect(find.text('HospiCare'), findsOneWidget);
  });
}
