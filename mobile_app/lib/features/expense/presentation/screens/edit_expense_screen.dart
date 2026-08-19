import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/custom_text_field.dart';

/// Screen 17: Edit Expense Screen
class EditExpenseScreen extends ConsumerStatefulWidget {
  const EditExpenseScreen({super.key});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController(text: 'Food');
  final _amountController = TextEditingController(text: 'Rs. 5,500');
  final _dateController = TextEditingController(text: '10 Aug 2026');
  final _descriptionController = TextEditingController(text: 'Grocery Shopping');

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
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
          'EDIT EXPENSE',
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
                CustomTextField(label: 'Amount', controller: _amountController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Date', controller: _dateController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Description', controller: _descriptionController, maxLines: 3),
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
