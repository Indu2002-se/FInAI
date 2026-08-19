import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';

/// Screen 27: Reports Dashboard
class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

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
          'REPORTS',
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
              title: 'Monthly Financial Report',
              subtitle: 'August 2026',
              leading: const Icon(Icons.description, color: Colors.blue, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Income vs Expense',
              subtitle: 'Last 6 months',
              leading: const Icon(Icons.bar_chart, color: Colors.green, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Category Breakdown',
              subtitle: 'This month',
              leading: const Icon(Icons.pie_chart, color: Colors.orange, size: 28),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'Savings Progress',
              subtitle: 'Year to date',
              leading: const Icon(Icons.trending_up, color: Colors.teal, size: 28),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
