import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/core/widgets/progress_bar.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../savings/data/models/savings_model.dart';
import '../../data/repositories/child_repository.dart';
import '../providers/child_provider.dart';
import '../providers/child_selection_provider.dart';

/// Screen 33: Child Savings Goal Screen
/// Displays details for a child's savings goal using live data.
class ChildSavingsGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoalModel? goal;

  const ChildSavingsGoalScreen({super.key, this.goal});

  @override
  ConsumerState<ChildSavingsGoalScreen> createState() =>
      _ChildSavingsGoalScreenState();
}

class _ChildSavingsGoalScreenState
    extends ConsumerState<ChildSavingsGoalScreen> {
  bool _isAddingMoney = false;

  void _showAddMoneyDialog(
      BuildContext context, SavingsGoalModel currentGoal, int? childId) {
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Add Money to Goal',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Adding savings towards "${currentGoal.title}"',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Amount (Rs.)',
                controller: amountController,
                keyboardType: TextInputType.number,
                hint: 'e.g. 500',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final amount = double.parse(amountController.text.trim());
                Navigator.of(dialogCtx).pop();
                await _contributeToGoal(currentGoal, amount, childId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _contributeToGoal(
      SavingsGoalModel goal, double amount, int? childId) async {
    setState(() => _isAddingMoney = true);
    try {
      final repo = ref.read(childRepositoryProvider);
      final targetChildId = childId ?? goal.childProfileId ?? 0;

      if (targetChildId > 0) {
        await repo.updateGoalProgress(targetChildId, goal.id, amount);
      }

      // Invalidate dashboards to refresh live amounts
      ref.invalidate(childDashboardProvider);
      if (targetChildId > 0) {
        ref.invalidate(parentViewChildDashboardProvider(targetChildId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully added Rs.${amount.toStringAsFixed(0)} to ${goal.title}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add savings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingMoney = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final selectedChild = ref.watch(selectedChildProvider);

    // If goal was passed in via navigation, use it
    if (widget.goal != null) {
      return _buildGoalDetails(
          context, widget.goal!, selectedChild?.id);
    }

    // Otherwise load dashboard goals
    final dashboardAsync = authState.maybeWhen(
      authenticated: (user) {
        if (user.isParent && selectedChild != null) {
          return ref.watch(parentViewChildDashboardProvider(selectedChild.id));
        }
        return ref.watch(childDashboardProvider);
      },
      orElse: () => throw Exception('Not authenticated'),
    );

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
            child:
                const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SAVINGS GOAL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $err', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(childDashboardProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (dashboard) {
            if (dashboard.savingsGoals.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.savings_outlined,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Savings Goals Yet',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create savings goals to start tracking your progress!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Back to Dashboard',
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              );
            }
            final firstGoal = dashboard.savingsGoals.first;
            return _buildGoalDetails(
                context, firstGoal, selectedChild?.id);
          },
        ),
      ),
    );
  }

  Widget _buildGoalDetails(
      BuildContext context, SavingsGoalModel goal, int? childId) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (goal.targetAmount - goal.currentAmount)
        .clamp(0.0, double.infinity);
    final categoryIcon = _getCategoryIcon(goal.category);
    final categoryColor = _getCategoryColor(goal.category);

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
            child:
                const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          goal.title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Goal Card Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.08),
                  border: Border.all(color: categoryColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(categoryIcon, size: 64, color: categoryColor),
                    const SizedBox(height: 16),
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rs.${goal.currentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: categoryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of Rs.${goal.targetAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ProgressBarWidget(progress: progress),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Complete',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoRow(
                  'Still Need',
                  remaining > 0
                      ? 'Rs.${remaining.toStringAsFixed(0)}'
                      : 'Goal Reached! 🎉'),
              _buildInfoRow('Category', goal.category),
              _buildInfoRow(
                  'Status',
                  goal.status.replaceAll('_', ' ').toUpperCase()),
              if (goal.deadline != null && goal.deadline!.isNotEmpty)
                _buildInfoRow('Deadline', goal.deadline!),
              if (goal.notes != null && goal.notes!.isNotEmpty)
                _buildInfoRow('Notes', goal.notes!),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Add Money',
                isLoading: _isAddingMoney,
                onPressed: () =>
                    _showAddMoneyDialog(context, goal, childId),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Dashboard',
                variant: ButtonVariant.outline,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'TOYS':
        return Icons.videogame_asset;
      case 'SPORTS':
        return Icons.sports_soccer;
      case 'BOOKS':
      case 'EDUCATION':
        return Icons.menu_book;
      case 'BIKE':
      case 'VEHICLE':
        return Icons.pedal_bike;
      case 'ELECTRONICS':
        return Icons.phone_android;
      case 'ART':
        return Icons.palette;
      default:
        return Icons.savings;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TOYS':
        return Colors.purple;
      case 'SPORTS':
        return Colors.green;
      case 'BOOKS':
      case 'EDUCATION':
        return Colors.brown;
      case 'BIKE':
      case 'VEHICLE':
        return Colors.blue;
      case 'ELECTRONICS':
        return Colors.indigo;
      default:
        return Colors.teal;
    }
  }
}
