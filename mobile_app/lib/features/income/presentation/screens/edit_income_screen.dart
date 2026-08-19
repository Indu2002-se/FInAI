import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';

/// Screen 14: Edit Income Screen
class EditIncomeScreen extends ConsumerStatefulWidget {
  const EditIncomeScreen({super.key});

  @override
  ConsumerState<EditIncomeScreen> createState() => _EditIncomeScreenState();
}

class _EditIncomeScreenState extends ConsumerState<EditIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController(text: 'Salary');
  final _amountController = TextEditingController(text: 'Rs. 150,000');
  final _dateController = TextEditingController(text: '01 Aug 2026');
  final _categoryController = TextEditingController(text: 'Salary');

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
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
          'EDIT INCOME',
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
                CustomTextField(label: 'Income Source', controller: _sourceController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Amount', controller: _amountController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Date', controller: _dateController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Category', controller: _categoryController),
                const SizedBox(height: 32),
                CustomButton(text: 'Update', onPressed: () {}),
                const SizedBox(height: 12),
                CustomButton(text: 'Delete', variant: ButtonVariant.outline, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
