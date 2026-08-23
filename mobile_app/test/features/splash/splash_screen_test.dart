import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/app/theme/app_theme.dart';
import 'package:mobile_app/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen displays the configured loading image', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SplashScreen()),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/main_start_loading.jpeg',
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
