// Basic Flutter widget test for FinAI splash screen.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app/app.dart';

void main() {
  testWidgets('app loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // Allow the initial frame to render
    await tester.pump();

    expect(find.text('FinAI'), findsOneWidget);
    expect(
      find.text('AI-Powered Personal Financial Management'),
      findsOneWidget,
    );

    // Cancel pending timers by pumping until idle
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
