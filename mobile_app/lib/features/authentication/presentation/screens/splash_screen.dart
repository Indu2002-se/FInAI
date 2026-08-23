import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';

/// Screen 1: Splash Screen
/// Wireframe: Logo + subtitle + loading spinner
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go(RouteNames.intro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'FinAI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  // color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Subtitle
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'AI-Powered Personal Financial Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  // color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                // color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
