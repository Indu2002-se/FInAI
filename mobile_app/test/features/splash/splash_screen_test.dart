import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/theme/app_theme.dart';
import 'package:mobile_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen displays the FinAI branding', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SplashScreen()),
    );

    expect(find.text('FinAI'), findsOneWidget);
    expect(
      find.text('AI-Powered Personal Financial Management'),
      findsOneWidget,
    );
  });
}
