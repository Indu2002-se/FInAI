import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/core/widgets/custom_button.dart';
import 'package:mobile_app/app/core/widgets/custom_text_field.dart';
import 'package:mobile_app/app/theme/app_theme.dart';

void main() {
  group('CustomButton', () {
    testWidgets('renders button text and triggers onPressed when tapped', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomButton(
              text: 'Save Goal',
              onPressed: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Save Goal'), findsOneWidget);

      await tester.tap(find.text('Save Goal'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('shows loading spinner when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: CustomButton(
              text: 'Processing...',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('CustomTextField', () {
    testWidgets('renders label and handles text input', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: CustomTextField(
              label: 'Monthly Income',
              hint: 'Enter amount',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Monthly Income'), findsOneWidget);
      expect(find.text('Enter amount'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '75000');
      expect(controller.text, '75000');
    });
  });
}
