import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/progress_bar.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';

/// Screen 18: Budget Dashboard Screen
class BudgetDashboardScreen extends ConsumerWidget {
  const BudgetDashboardScreen({super.key});

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
              border: Border.all(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
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
          'BUDGET DASHBOARD',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildBudgetCard('Food & Groceries', 15000, 12000, 0.8),
                  const SizedBox(height: 16),
                  _buildBudgetCard('Transport', 8000, 6500, 0.8125),
                  const SizedBox(height: 16),
                  _buildBudgetCard('Utilities', 5000, 3200, 0.64),
                  const SizedBox(height: 16),
                  _buildBudgetCard('Entertainment', 10000, 2000, 0.2),
                  const SizedBox(height: 16),
                  _buildBudgetCard('Healthcare', 7000, 0, 0.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(text: '+ Create Budget', onPressed: () {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildBudgetCard(String category, double budget, double spent, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                'Rs.${spent.toStringAsFixed(0)} / Rs.${budget.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBarWidget(progress: progress),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% used',
            style: TextStyle(
              fontSize: 11,
              color: progress > 0.8 ? Colors.red[700] : Colors.grey[600],
              fontWeight: progress > 0.8 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
