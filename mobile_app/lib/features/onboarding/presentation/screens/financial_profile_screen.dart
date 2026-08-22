import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../../data/repositories/wizard_repository.dart';
import '../providers/onboarding_state.dart';

/// Screen 9: Financial Profile Screen (Step 4 of 4)
/// Final step: collects expense/savings/debt data, then submits wizard to backend
/// and triggers AI analysis before navigating to dashboard.
class FinancialProfileScreen extends ConsumerStatefulWidget {
  const FinancialProfileScreen({super.key});

  @override
  ConsumerState<FinancialProfileScreen> createState() =>
      _FinancialProfileScreenState();
}

class _FinancialProfileScreenState
    extends ConsumerState<FinancialProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyExpenseController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _debtController = TextEditingController();
  String _selectedKnowledgeLevel = 'BEGINNER';
  String _selectedRisk = 'Medium';
  bool _isSubmitting = false;
  String? _errorMessage;

  /// Backend FinancialKnowledgeLevel enum values
  static const _knowledgeLevels = [
    ('Beginner', 'BEGINNER'),
    ('Intermediate', 'INTERMEDIATE'),
    ('Advanced', 'ADVANCED'),
  ];

  static const _riskLevels = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    if (state.monthlyExpense > 0) {
      _monthlyExpenseController.text = state.monthlyExpense.toStringAsFixed(0);
    }
    if (state.savingsGoal > 0) {
      _savingsGoalController.text = state.savingsGoal.toStringAsFixed(0);
    }
    if (state.currentDebt > 0) {
      _debtController.text = state.currentDebt.toStringAsFixed(0);
    }
    if (state.financialKnowledgeLevel.isNotEmpty) {
      _selectedKnowledgeLevel = state.financialKnowledgeLevel;
    }
    if (state.riskTolerance.isNotEmpty) {
      _selectedRisk = state.riskTolerance;
    }
  }

  @override
  void dispose() {
    _monthlyExpenseController.dispose();
    _savingsGoalController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate expense vs income
    final income = ref.read(onboardingProvider).monthlyIncome;
    final expense =
        double.tryParse(_monthlyExpenseController.text.trim()) ?? 0;
    if (expense > income) {
      setState(() => _errorMessage =
          'Monthly expense (${expense.toStringAsFixed(0)}) cannot exceed monthly income (${income.toStringAsFixed(0)}).');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Save step 4 data into the provider
      ref.read(onboardingProvider.notifier).updateFinancial(
            monthlyExpense: expense,
            savingsGoal:
                double.tryParse(_savingsGoalController.text.trim()) ?? 0,
            financialKnowledgeLevel: _selectedKnowledgeLevel,
            currentDebt: double.tryParse(_debtController.text.trim()) ?? 0,
            riskTolerance: _selectedRisk,
          );

      // Build payload and submit to backend
      final payload = ref.read(onboardingProvider).toWizardJson();
      final wizardRepo = ref.read(wizardRepositoryProvider);
      await wizardRepo.saveWizard(payload);

      // Navigate to dashboard — AI analysis is triggered server-side
      if (mounted) {
        ref.read(onboardingProvider.notifier).reset();
        context.go(RouteNames.dashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Icon(Icons.arrow_back, size: 16),
          ),
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
        title: const Text(
          'FINANCIAL PROFILE',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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
                Center(
                  child: Text(
                    'STEP 4 OF 4',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                // Show income from previous step
                Consumer(builder: (context, ref, _) {
                  final income = ref.watch(onboardingProvider).monthlyIncome;
                  return Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Monthly Income:',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            'LKR ${income.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.teal),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Monthly Expense (LKR) *',
                  controller: _monthlyExpenseController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 40000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your monthly expenses';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n < 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Monthly Savings Goal (LKR) *',
                  controller: _savingsGoalController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 15000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter a savings goal (0 if none)';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n < 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Current Total Debt (LKR)',
                  controller: _debtController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: '0 if no debt',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedKnowledgeLevel,
                  decoration: const InputDecoration(
                    labelText: 'Financial Knowledge Level *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _knowledgeLevels
                      .map((opt) => DropdownMenuItem(
                            value: opt.$2,
                            child: Text(opt.$1),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedKnowledgeLevel = v!),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please select a level' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRisk,
                  decoration: const InputDecoration(
                    labelText: 'Risk Tolerance',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _riskLevels
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRisk = v!),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                _isSubmitting
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Setting up your AI financial profile…',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      )
                    : CustomButton(
                        text: 'Finish Setup',
                        onPressed: _handleFinish,
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
