import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/models/savings_model.dart';
import '../../data/repositories/savings_repository.dart';
import '../providers/savings_provider.dart';

/// Screen 30: Create Savings Goal — Live Backend Connected
class CreateSavingsGoalScreen extends ConsumerStatefulWidget {
  const CreateSavingsGoalScreen({super.key});

  @override
  ConsumerState<CreateSavingsGoalScreen> createState() =>
      _CreateSavingsGoalScreenState();
}

class _CreateSavingsGoalScreenState
    extends ConsumerState<CreateSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialAmountController = TextEditingController();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 180));
  String _selectedCategory = 'Emergency Fund';
  bool _isLoading = false;

  static const _categories = [
    'Emergency Fund',
    'Vacation & Travel',
    'Vehicle',
    'Housing & Property',
    'Education',
    'Gadgets & Tech',
    'General Savings',
  ];

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _initialAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final target = double.tryParse(_targetAmountController.text.trim());
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid target amount')),
      );
      return;
    }

    final initial =
        double.tryParse(_initialAmountController.text.trim()) ?? 0.0;

    setState(() => _isLoading = true);

    try {
      final deadlineStr =
          "${_selectedDeadline.year.toString().padLeft(4, '0')}-${_selectedDeadline.month.toString().padLeft(2, '0')}-${_selectedDeadline.day.toString().padLeft(2, '0')}";

      final goal = SavingsGoalModel(
        id: 0,
        title: _goalNameController.text.trim(),
        targetAmount: target,
        currentAmount: initial,
        progressPercentage: target > 0 ? (initial / target) * 100.0 : 0.0,
        deadline: deadlineStr,
        status: 'IN_PROGRESS',
        category: _selectedCategory,
        icon: 'savings',
      );

      final repo = ref.read(savingsRepositoryProvider);
      await repo.createGoal(goal);

      // Invalidate relevant providers to refresh UI data
      ref.invalidate(savingsGoalsListProvider);
      ref.invalidate(dashboardFutureProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Savings goal created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create savings goal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadlineDisplay =
        "${_selectedDeadline.year}-${_selectedDeadline.month.toString().padLeft(2, '0')}-${_selectedDeadline.day.toString().padLeft(2, '0')}";

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
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'CREATE SAVINGS GOAL',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Goal Name *',
                  controller: _goalNameController,
                  hint: 'e.g. Emergency Fund / Vacation to Bali',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter goal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Goal Category *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Target Amount (LKR) *',
                  controller: _targetAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 250000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter target amount';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Initial Amount Already Saved (Optional)',
                  controller: _initialAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: '0',
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDeadline,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Target Deadline *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: Text(
                      deadlineDisplay,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Save Savings Goal',
                        onPressed: _handleSave,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
