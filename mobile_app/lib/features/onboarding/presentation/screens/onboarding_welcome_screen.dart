import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/router/route_names.dart';

/// Screen 5: Onboarding Welcome Screen
/// Wireframe: Logo + welcome message + Start button
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 24,
                  ),
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
              ),
              const SizedBox(height: 40),
              // Welcome message
              Text(
                'Welcome to FinAI! Manage income, expenses and budgets, get AI-powered financial insights, and reach your savings goals — all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  // color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const Spacer(),
              // Start button
              CustomButton(
                text: 'Start',
                onPressed: () => context.push(RouteNames.onboardingPersonal),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
