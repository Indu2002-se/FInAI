import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';

/// Screen 8: Employment and Income Screen (Step 3 of 4)
/// Wireframe: Employment Status, Monthly Income, Income Source
class EmploymentIncomeScreen extends ConsumerStatefulWidget {
  const EmploymentIncomeScreen({super.key});

  @override
  ConsumerState<EmploymentIncomeScreen> createState() =>
      _EmploymentIncomeScreenState();
}

class _EmploymentIncomeScreenState
    extends ConsumerState<EmploymentIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employmentStatusController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _incomeSourceController = TextEditingController();

  @override
  void dispose() {
    _employmentStatusController.dispose();
    _monthlyIncomeController.dispose();
    _incomeSourceController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      context.push(RouteNames.onboardingFinancial);
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
            child: const Icon(
              Icons.arrow_back,
              // color: Colors.black87,
              size: 16,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'EMPLOYMENT AND INCOME',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            // color: Colors.black87,
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
                Center(
                  child: Text(
                    'STEP 3 OF 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      // color: Colors.grey[600],
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Employment Status',
                  controller: _employmentStatusController,
                  hint: 'Employed / Self-Employed / Unemployed',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employment status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Monthly Income',
                  controller: _monthlyIncomeController,
                  keyboardType: TextInputType.number,
                  hint: 'Rs. ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter monthly income';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Income Source',
                  controller: _incomeSourceController,
                  hint: 'Salary / Business / Investment',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter income source';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Continue',
                  onPressed: _handleContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
