import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/onboarding_state.dart';

/// Screen 7: Household Information Screen (Step 2 of 4)
class HouseholdInformationScreen extends ConsumerStatefulWidget {
  const HouseholdInformationScreen({super.key});

  @override
  ConsumerState<HouseholdInformationScreen> createState() =>
      _HouseholdInformationScreenState();
}

class _HouseholdInformationScreenState
    extends ConsumerState<HouseholdInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _householdSizeController = TextEditingController();
  final _dependentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    if (state.householdSize > 0) {
      _householdSizeController.text = state.householdSize.toString();
    }
    if (state.dependentsCount >= 0) {
      _dependentsController.text = state.dependentsCount.toString();
    }
  }

  @override
  void dispose() {
    _householdSizeController.dispose();
    _dependentsController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(onboardingProvider.notifier).updateHousehold(
          householdSize: int.tryParse(_householdSizeController.text.trim()) ?? 1,
          dependentsCount: int.tryParse(_dependentsController.text.trim()) ?? 0,
        );
    context.push(RouteNames.onboardingEmployment);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'HOUSEHOLD INFORMATION'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepIndicator('STEP 2 OF 4'),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Household Size',
                  controller: _householdSizeController,
                  keyboardType: TextInputType.number,
                  hint: 'Total people living with you',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter household size';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) return 'Must be at least 1';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Dependents',
                  controller: _dependentsController,
                  keyboardType: TextInputType.number,
                  hint: 'Number of dependents (e.g. children)',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter dependents (0 if none)';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 0) return 'Must be 0 or more';
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
