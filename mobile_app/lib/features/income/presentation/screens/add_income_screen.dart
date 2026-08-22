import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../ai_insights/presentation/providers/ai_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';
import '../providers/income_provider.dart';

/// Screen 13: Add Income Screen — Live Backend Connected
class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'SALARY';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isLoading = false;

  static const _categories = [
    ('Monthly Salary', 'SALARY'),
    ('Business Income', 'BUSINESS'),
    ('Investment & Dividends', 'INVESTMENT'),
    ('Freelance & Consulting', 'FREELANCE'),
    ('Windfall & Bonus', 'WINDFALL'),
    ('Agriculture & Farming', 'AGRICULTURE'),
    ('Other Income', 'OTHER'),
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid income amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr =
          "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

      final income = IncomeModel(
        id: 0,
        source: _sourceController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        incomeDate: dateStr,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isRecurring: _isRecurring,
      );

      final repo = ref.read(incomeRepositoryProvider);
      await repo.createIncome(income);

      // Invalidate relevant providers to refresh UI data and recalculate AI models
      ref.invalidate(incomeListProvider);
      ref.invalidate(dashboardFutureProvider);
      ref.invalidate(latestAiAnalysisProvider);
      ref.invalidate(riskPredictionProvider);
      ref.invalidate(expenseForecastProvider);
      ref.invalidate(aiRecommendationProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Income added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add income: $e'),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateDisplay =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

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
          'ADD INCOME',
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
                  label: 'Income Source *',
                  controller: _sourceController,
                  hint: 'e.g. Main Job / Client Project',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter income source';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Income Category *',
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
                  label: 'Amount (LKR) *',
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 75000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter income amount';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Income Date *',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 20),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: Text(
                      dateDisplay,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Recurring Monthly Income',
                      style: TextStyle(fontSize: 14)),
                  value: _isRecurring,
                  onChanged: (v) => setState(() => _isRecurring = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description (Optional)',
                  controller: _descriptionController,
                  maxLines: 3,
                  hint: 'Add notes about this income...',
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Save Income',
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
