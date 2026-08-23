// Basic Flutter widget test for FinAI splash screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/app.dart';

void main() {
  testWidgets('app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // Allow the initial frame to render
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('AI-Powered Personal Financial Management'), findsNothing);
  });
}
