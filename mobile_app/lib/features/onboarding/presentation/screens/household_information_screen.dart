import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';

/// Screen 7: Household Information Screen (Step 2 of 4)
/// Wireframe: Household Size, Dependents, Family Information
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
  final _familyInfoController = TextEditingController();

  @override
  void dispose() {
    _householdSizeController.dispose();
    _dependentsController.dispose();
    _familyInfoController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      context.push(RouteNames.onboardingEmployment);
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
          'HOUSEHOLD INFORMATION',
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
                    'STEP 2 OF 4',
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
                  label: 'Household Size',
                  controller: _householdSizeController,
                  keyboardType: TextInputType.number,
                  hint: 'Number of people in household',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter household size';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Dependents',
                  controller: _dependentsController,
                  keyboardType: TextInputType.number,
                  hint: 'Number of dependents',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of dependents';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Family Information',
                  controller: _familyInfoController,
                  maxLines: 3,
                  hint: 'Additional family details',
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
