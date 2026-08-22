import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/onboarding_state.dart';

/// Screen 6: Personal Information Screen (Step 1 of 4)
class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedGender = 'Male';

  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // Pre-fill from existing state if user navigates back
    final state = ref.read(onboardingProvider);
    if (state.name.isNotEmpty) _nameController.text = state.name;
    if (state.age > 0) _ageController.text = state.age.toString();
    if (state.location.isNotEmpty) _locationController.text = state.location;
    if (state.gender.isNotEmpty) _selectedGender = state.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!_formKey.currentState!.validate()) return;
    // Save to provider
    ref.read(onboardingProvider.notifier).updatePersonal(
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 0,
          gender: _selectedGender,
          location: _locationController.text.trim(),
        );
    context.push(RouteNames.onboardingHousehold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, 'PERSONAL INFORMATION'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _stepIndicator('STEP 1 OF 4'),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'Enter your full name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 28',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter your age';
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 18 || n > 100) return 'Enter a valid age (18–100)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Gender dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: _genders
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'City / Location',
                  controller: _locationController,
                  hint: 'e.g. Colombo, Sri Lanka',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter your location' : null,
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
