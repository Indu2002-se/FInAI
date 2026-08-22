import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/onboarding_state.dart';

/// Screen 8: Employment and Income Screen (Step 3 of 4)
class EmploymentIncomeScreen extends ConsumerStatefulWidget {
  const EmploymentIncomeScreen({super.key});

  @override
  ConsumerState<EmploymentIncomeScreen> createState() =>
      _EmploymentIncomeScreenState();
}

class _EmploymentIncomeScreenState
    extends ConsumerState<EmploymentIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyIncomeController = TextEditingController();
  String _selectedStatus = 'EMPLOYED';

  /// Backend EmploymentStatus enum values
  static const _statusOptions = [
    ('Employed', 'EMPLOYED'),
    ('Self-Employed', 'SELF_EMPLOYED'),
    ('Unemployed', 'UNEMPLOYED'),
    ('Student', 'STUDENT'),
    ('Retired', 'RETIRED'),
    ('Other', 'OTHER'),
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    if (state.monthlyIncome > 0) {
      _monthlyIncomeController.text = state.monthlyIncome.toStringAsFixed(0);
    }
    if (state.employmentStatus.isNotEmpty) {
      _selectedStatus = state.employmentStatus;
    }
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(onboardingProvider.notifier).updateEmployment(
          employmentStatus: _selectedStatus,
          monthlyIncome:
              double.tryParse(_monthlyIncomeController.text.trim()) ?? 0,
        );
    context.push(RouteNames.onboardingFinancial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'EMPLOYMENT AND INCOME'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepIndicator('STEP 3 OF 4'),
                const SizedBox(height: 32),
                // Employment status dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Employment Status *',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _statusOptions
                      .map((opt) => DropdownMenuItem(
                            value: opt.$2,
                            child: Text(opt.$1),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Please select status' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Monthly Income (LKR) *',
                  controller: _monthlyIncomeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 75000',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your monthly income';
                    }
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter a valid income amount';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(text: 'Continue', onPressed: _handleContinue),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

AppBar _buildAppBar(BuildContext context, String title) {
  return AppBar(
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
      onPressed: () => context.pop(),
    ),
    title: Text(
      title,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
    ),
    centerTitle: true,
  );
}

Widget _stepIndicator(String label) {
  return Center(
    child: Text(
      label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
          letterSpacing: 0.8),
    ),
  );
}
