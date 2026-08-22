import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/budget_provider.dart';

/// Screen 18: Budget Dashboard Screen — Live Data Connected
class BudgetDashboardScreen extends ConsumerWidget {
  const BudgetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(currentBudgetStatusProvider);

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
              context.go(RouteNames.dashboard);
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
        child: statusAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Error loading budgets: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentBudgetStatusProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (status) {
            final categoryBudgets = status.categoryBudgets;
            final overallUsage = (status.overallUsagePercentage / 100.0).clamp(0.0, 1.0);

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(currentBudgetStatusProvider),
              child: Column(
                children: [
                  // Overall budget summary card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowMedium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL MONTHLY BUDGET',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rs. ${status.totalSpent.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '/ Rs. ${status.totalAllocated.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: overallUsage,
                            minHeight: 8,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              overallUsage > 0.9
                                  ? Colors.redAccent
                                  : overallUsage > 0.7
                                      ? Colors.amberAccent
                                      : Colors.greenAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${status.overallUsagePercentage.toStringAsFixed(1)}% of total monthly budget spent',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: categoryBudgets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pie_chart_outline,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No category budgets set for this month.',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: categoryBudgets.length,
                            itemBuilder: (context, index) {
                              final item = categoryBudgets[index];
                              final usage = (item.usagePercentage / 100.0).clamp(0.0, 1.0);
                              final isOver = item.isOverBudget || item.spentAmount > item.allocatedAmount;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isOver
                                        ? Colors.red.shade300
                                        : Colors.grey.shade200,
                                    width: isOver ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppTheme.shadowSoft,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.category.replaceAll('_', ' '),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Rs.${item.spentAmount.toStringAsFixed(0)} / Rs.${item.allocatedAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOver
                                                ? AppColors.error
                                                : Colors.grey[700],
                                            fontWeight: isOver
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: usage,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          isOver
                                              ? AppColors.error
                                              : usage > 0.7
                                                  ? AppColors.warning
                                                  : AppColors.success,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${item.usagePercentage.toStringAsFixed(0)}% used',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isOver
                                                ? AppColors.error
                                                : Colors.grey[600],
                                            fontWeight: isOver
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          isOver
                                              ? 'Overspent by Rs.${(item.spentAmount - item.allocatedAmount).toStringAsFixed(0)}'
                                              : 'Rs.${item.remainingAmount.toStringAsFixed(0)} left',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isOver
                                                ? AppColors.error
                                                : AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: '+ Create Budget',
                      onPressed: () => context.push(RouteNames.createBudget),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }
}
