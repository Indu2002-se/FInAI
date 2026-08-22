import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../providers/budget_provider.dart';

/// Screen 19: Create Budget Screen — Live Backend Connected
class CreateBudgetScreen extends ConsumerStatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _selectedCategory = 'FOOD';
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  static const _categories = [
    ('Food & Groceries', 'FOOD'),
    ('Utilities & Bills', 'UTILITIES'),
    ('Transportation & Fuel', 'TRANSPORTATION'),
    ('Education & Tuition', 'EDUCATION'),
    ('Healthcare & Medicine', 'HEALTHCARE'),
    ('Entertainment & Leisure', 'ENTERTAINMENT'),
    ('Other Expenses', 'OTHER'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid allocated amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final monthStr =
          "${_selectedMonth.year.toString().padLeft(4, '0')}-${_selectedMonth.month.toString().padLeft(2, '0')}";

      final budget = BudgetModel(
        id: 0,
        category: _selectedCategory,
        allocatedAmount: amount,
        spentAmount: 0.0,
        remainingAmount: amount,
        usagePercentage: 0.0,
        isOverBudget: false,
        budgetMonth: monthStr,
      );

      final repo = ref.read(budgetRepositoryProvider);
      await repo.createBudget(budget);

      // Invalidate relevant providers to refresh UI data
      ref.invalidate(budgetStatusProvider);
      ref.invalidate(budgetListProvider);
      ref.invalidate(dashboardFutureProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create budget: $e'),
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
    final monthDisplay =
        "${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}";

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
          'CREATE BUDGET',
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
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Expense Category *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.$2,
                            child: Text(c.$1),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Allocated Monthly Limit (LKR) *',
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 20000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter monthly limit';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Budget Month (YYYY-MM)',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  child: Text(
                    monthDisplay,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Save Budget',
                        onPressed: _handleCreate,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
