import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/stat_row.dart';
import '../../../../app/core/widgets/transaction_list_item.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';

/// Screen 15: Expense List Screen
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

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
          'EXPENSE LIST',
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: StatRow(
                items: [
                  StatItem(label: 'Total Expenses', value: 'Rs.45,000', color: Colors.red[700]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Categories: Food · Transport · Utilities · Entertainment',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text('Search / Filter', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  children: const [
                    TransactionListItem(
                      title: 'Grocery Shopping',
                      subtitle: 'Food',
                      value: '-Rs.5,500',
                      icon: Icons.shopping_cart,
                      isIncome: false,
                    ),
                    TransactionListItem(
                      title: 'Electricity Bill',
                      subtitle: 'Utilities',
                      value: '-Rs.3,200',
                      icon: Icons.bolt,
                      isIncome: false,
                    ),
                    TransactionListItem(
                      title: 'Fuel',
                      subtitle: 'Transport',
                      value: '-Rs.4,000',
                      icon: Icons.local_gas_station,
                      isIncome: false,
                    ),
                    TransactionListItem(
                      title: 'Movie Tickets',
                      subtitle: 'Entertainment',
                      value: '-Rs.2,000',
                      icon: Icons.movie,
                      isIncome: false,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(text: '+ Add Expense', onPressed: () {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
