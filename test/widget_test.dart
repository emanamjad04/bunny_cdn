import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bunny_cdn/InputScreen.dart';

void main() {
  testWidgets('partner login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Partner test login'), findsOneWidget);
    expect(find.text('Open BOGO'), findsOneWidget);
  });
}
