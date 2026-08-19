import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';

/// Screen 20: Edit Budget Screen
class EditBudgetScreen extends ConsumerStatefulWidget {
  const EditBudgetScreen({super.key});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController(text: 'Food & Groceries');
  final _amountController = TextEditingController(text: 'Rs. 15,000');
  final _periodController = TextEditingController(text: 'Monthly');

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _periodController.dispose();
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
          'EDIT BUDGET',
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
                CustomTextField(label: 'Category', controller: _categoryController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Budget Amount', controller: _amountController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Period', controller: _periodController),
                const SizedBox(height: 32),
                CustomButton(text: 'Update Budget', onPressed: () {}),
                const SizedBox(height: 12),
                CustomButton(text: 'Delete Budget', variant: ButtonVariant.outline, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
