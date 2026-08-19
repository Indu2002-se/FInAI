import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';

/// Screen 30: Create Savings Goal
class CreateSavingsGoalScreen extends ConsumerStatefulWidget {
  const CreateSavingsGoalScreen({super.key});

  @override
  ConsumerState<CreateSavingsGoalScreen> createState() => _CreateSavingsGoalScreenState();
}

class _CreateSavingsGoalScreenState extends ConsumerState<CreateSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _initialAmountController = TextEditingController();

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _deadlineController.dispose();
    _initialAmountController.dispose();
    super.dispose();
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
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CREATE SAVINGS GOAL',
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
              children: [
                CustomTextField(label: 'Goal Name', controller: _goalNameController),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Target Amount',
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  hint: 'Rs. ',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Deadline',
                  controller: _deadlineController,
                  hint: 'DD/MM/YYYY',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Initial Amount (Optional)',
                  controller: _initialAmountController,
                  keyboardType: TextInputType.number,
                  hint: 'Rs. ',
                ),
                const SizedBox(height: 32),
                CustomButton(text: 'Create Goal', onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
