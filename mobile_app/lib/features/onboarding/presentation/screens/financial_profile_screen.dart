import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';

/// Screen 9: Financial Profile Screen (Step 4 of 4)
/// Wireframe: Savings, Debt, Financial Goals, Risk Information
class FinancialProfileScreen extends ConsumerStatefulWidget {
  const FinancialProfileScreen({super.key});

  @override
  ConsumerState<FinancialProfileScreen> createState() =>
      _FinancialProfileScreenState();
}

class _FinancialProfileScreenState
    extends ConsumerState<FinancialProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _savingsController = TextEditingController();
  final _debtController = TextEditingController();
  final _goalsController = TextEditingController();
  final _riskController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _savingsController.dispose();
    _debtController.dispose();
    _goalsController.dispose();
    _riskController.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Call wizard service to save profile data
      // For now, just navigate to dashboard after a short delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        // Navigate to dashboard after completion
        context.go(RouteNames.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
        title: const Text(
          'FINANCIAL PROFILE',
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
                    'STEP 4 OF 4',
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
                  label: 'Savings Information',
                  controller: _savingsController,
                  keyboardType: TextInputType.number,
                  hint: 'Current savings amount (optional)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Debt Information',
                  controller: _debtController,
                  keyboardType: TextInputType.number,
                  hint: 'Current debt amount (optional)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Financial Goals',
                  controller: _goalsController,
                  maxLines: 3,
                  hint: 'What are your financial goals? (optional)',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Risk-Related Information',
                  controller: _riskController,
                  maxLines: 2,
                  hint: 'Risk tolerance: Low / Medium / High (optional)',
                ),
                const SizedBox(height: 32),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Finish Setup',
                        onPressed: _handleFinish,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
