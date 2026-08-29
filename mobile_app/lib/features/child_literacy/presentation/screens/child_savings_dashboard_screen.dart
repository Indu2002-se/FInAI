import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/progress_bar.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../data/repositories/child_repository.dart';
import '../providers/child_provider.dart';
import '../providers/child_selection_provider.dart';

Future<void> _showCreateGoalDialog(
  BuildContext context,
  WidgetRef ref,
  int childId,
) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final created = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Add Savings Goal',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Goal title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target amount (Rs.)'),
              validator: (v) {
                final n = double.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.pop(dialogCtx, true);
            }
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );

  if (created != true) return;

  try {
    final repo = ref.read(childRepositoryProvider);
    await repo.createChildSavingsGoal(
      childId,
      ChildSavingsGoalModel(
        goalName: titleController.text.trim(),
        targetAmount: double.parse(amountController.text.trim()),
        currentAmount: 0,
        category: 'Toy / Reward',
      ),
    );
    ref.invalidate(childDashboardProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savings goal created'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create goal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Screen 32: Child Savings Dashboard
/// Displays child's savings, goals, and activities
class ChildSavingsDashboardScreen extends ConsumerWidget {
  const ChildSavingsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    final isParentWithoutChild = authState.maybeWhen(
      authenticated: (user) => user.isParent && selectedChild == null,
      orElse: () => false,
    );
    if (isParentWithoutChild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go(RouteNames.childProfileSelector);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dashboardAsync = ref.watch(childDashboardProvider);

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
            authState.whenOrNull(
              authenticated: (user) {
                if (user.isParent) {
                  context.go(RouteNames.childProfileSelector);
                } else {
                  ref.read(authNotifierProvider.notifier).logout();
                  context.go(RouteNames.userTypeSelection);
                }
              },
            );
          },
        ),
        title: authState.maybeWhen(
          authenticated: (user) {
            if (user.isParent && selectedChild != null) {
              return Text(
                '${selectedChild.name.toUpperCase()}\'S SAVINGS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              );
            }
            return const Text(
              'MY SAVINGS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            );
          },
          orElse: () => const Text(''),
        ),
        centerTitle: true,
        actions: [
          // Switch child button (only for parents)
          authState.maybeWhen(
            authenticated: (user) {
              if (user.isParent) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () => context.go(RouteNames.childProfileSelector),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, size: 16, color: AppColors.darkTeal),
                            const SizedBox(width: 4),
                            Text(
                              'Switch',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(childDashboardProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (dashboard) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Savings Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.savings, color: Colors.green, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Rs.${dashboard.currentSavings.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Savings',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Savings Goals Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MY GOALS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Edit button for parents
                    authState.maybeWhen(
                      authenticated: (user) {
                        if (user.isParent && selectedChild != null) {
                          return GestureDetector(
                            onTap: () => _showCreateGoalDialog(
                              context,
                              ref,
                              selectedChild.id,
                            ),
                            child: Text(
                              'Add Goal',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTeal,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Goals List
                if (dashboard.savingsGoals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No savings goals yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ...dashboard.savingsGoals.map((goal) {
                    final progress = goal.targetAmount > 0 
                        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
                        : 0.0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildGoalCard(
                        context,
                        goal,
                        progress,
                        _getIconForCategory(goal.category),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),

                InfoCard(
                  title: 'Quizzes & Badges',
                  subtitle: '${dashboard.recommendedQuizzes.length} quizzes available',
                  leading: const Icon(Icons.task_alt, color: Colors.blue, size: 28),
                  onTap: () => context.push(RouteNames.choresRewards),
                ),
                const SizedBox(height: 12),

                InfoCard(
                  title: 'Financial Quiz',
                  subtitle: 'Test your knowledge & earn points!',
                  leading: const Icon(Icons.quiz, color: Colors.orange, size: 28),
                  onTap: () => context.push(RouteNames.financialQuiz),
                ),
                const SizedBox(height: 12),

                InfoCard(
                  title: 'My Wishlist',
                  subtitle: '${dashboard.savingsGoals.length} wishlist goals',
                  leading: const Icon(Icons.star, color: Colors.amber, size: 28),
                  onTap: () => context.push(RouteNames.wishlist),
                ),
                const SizedBox(height: 12),

                InfoCard(
                  title: 'My Rewards',
                  subtitle: '${dashboard.recentRewards.length} earned badges',
                  leading: const Icon(Icons.emoji_events, color: Colors.purple, size: 28),
                  onTap: () => context.push(RouteNames.rewards),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, dynamic goal, double progress, IconData icon) {
    return InkWell(
      onTap: () => context.push(RouteNames.childSavingsGoal, extra: goal),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs.${goal.currentAmount.toStringAsFixed(0)} / Rs.${goal.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            ProgressBarWidget(progress: progress),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% Complete',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'TOYS':
        return Icons.videogame_asset;
      case 'SPORTS':
        return Icons.sports_soccer;
      case 'BOOKS':
        return Icons.book;
      case 'BIKE':
        return Icons.pedal_bike;
      case 'EDUCATION':
        return Icons.school;
      default:
        return Icons.shopping_bag;
    }
  }
}
