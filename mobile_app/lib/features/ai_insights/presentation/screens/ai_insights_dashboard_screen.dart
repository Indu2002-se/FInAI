import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';

/// Screen 21: AI Insights Dashboard
class AIInsightsDashboardScreen extends ConsumerWidget {
  const AIInsightsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back, size: 16),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text(
          'AI INSIGHTS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InfoCard(
              title: 'Financial Health Score',
              subtitle: '78 / 100',
              leading: const Icon(Icons.favorite, color: Colors.green, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Financial Risk Prediction',
              subtitle: 'Low Risk',
              leading: const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Expense Forecast',
              subtitle: 'Next month: Rs.48,500',
              leading: const Icon(Icons.trending_up, color: Colors.blue, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'AI Recommendations',
              subtitle: '3 new recommendations',
              leading: const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}
