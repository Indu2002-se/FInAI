import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/detected_transaction.dart';
import '../providers/transaction_detection_provider.dart';

class TransactionReviewPage extends ConsumerStatefulWidget {
  final DetectedTransactionModel transaction;

  const TransactionReviewPage({super.key, required this.transaction});

  @override
  ConsumerState<TransactionReviewPage> createState() => _TransactionReviewPageState();
}

class _TransactionReviewPageState extends ConsumerState<TransactionReviewPage> {
  late TextEditingController _amountController;
  late TextEditingController _merchantController;
  late TextEditingController _descriptionController;
  late TextEditingController _paymentMethodController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  late String _transactionType;

  final List<String> _expenseCategories = [
    'FOOD',
    'UTILITIES',
    'TRANSPORTATION',
    'HEALTHCARE',
    'EDUCATION',
    'ENTERTAINMENT',
    'OTHER',
  ];

  final List<String> _incomeCategories = [
    'SALARY',
    'BUSINESS',
    'INVESTMENT',
    'FREELANCE',
    'AGRICULTURE',
    'WINDFALL',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(text: t.amount.toStringAsFixed(2));
    _merchantController = TextEditingController(text: t.merchant ?? '');
    _descriptionController = TextEditingController(text: t.merchant ?? 'Detected transaction');
    _paymentMethodController = TextEditingController(text: t.sourceApp ?? t.sourceType);
    _transactionType = t.transactionType;

    final categories = _transactionType == 'CREDIT' ? _incomeCategories : _expenseCategories;
    if (t.suggestedCategory != null && categories.contains(t.suggestedCategory!.toUpperCase())) {
      _selectedCategory = t.suggestedCategory!.toUpperCase();
    } else {
      _selectedCategory = categories.first;
    }

    _selectedDate = DateTime.tryParse(t.transactionDate ?? '') ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _descriptionController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDebit = _transactionType == 'DEBIT';
    final isCredit = _transactionType == 'CREDIT';
    final categories = isCredit ? _incomeCategories : _expenseCategories;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detection Source Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tealExtraLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkTeal.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.transaction.sourceType == 'SMS' ? Icons.sms : Icons.notifications_active,
                    color: AppColors.darkTeal,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected from ${widget.transaction.sourceType} (${widget.transaction.sourceSender ?? widget.transaction.sourceApp ?? 'Bank'})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Confidence Score: ${(widget.transaction.confidence * 100).toInt()}% match',
                          style: const TextStyle(fontSize: 11, color: AppColors.mediumGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount
                    const Text('Amount (LKR)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Type Selector
                    const Text('Transaction Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Expense (Debit)')),
                            selected: _transactionType == 'DEBIT',
                            selectedColor: AppColors.darkTeal.withOpacity(0.2),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _transactionType = 'DEBIT';
                                  _selectedCategory = _expenseCategories.first;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Income (Credit)')),
                            selected: _transactionType == 'CREDIT',
                            selectedColor: AppColors.success.withOpacity(0.2),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _transactionType = 'CREDIT';
                                  _selectedCategory = _incomeCategories.first;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Category Dropdown
                    const Text('Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: categories.contains(_selectedCategory) ? _selectedCategory : categories.first,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Merchant / Payee
                    const Text('Merchant / Payee / Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _merchantController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'e.g. Keells Super, Dialog, Salary',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description / Note
                    const Text('Description / Notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        hintText: 'Optional notes for this transaction',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Picker Row
                    const Text('Transaction Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDebit ? AppColors.darkTeal : AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  isDebit ? 'Confirm & Save as Expense' : 'Confirm & Save as Income',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveAndConfirm,
              ),
            ),

            const SizedBox(height: 12),

            // Ignore Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Ignore this Transaction'),
                onPressed: _ignore,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAndConfirm() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? widget.transaction.amount;
    final isDebit = _transactionType == 'DEBIT';

    final payload = ConfirmTransactionPayload(
      amount: amount,
      expenseCategory: isDebit ? _selectedCategory : null,
      incomeCategory: !isDebit ? _selectedCategory : null,
      description: _descriptionController.text.trim(),
      transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      paymentMethodOrSource: _merchantController.text.trim().isNotEmpty
          ? _merchantController.text.trim()
          : (widget.transaction.sourceApp ?? widget.transaction.sourceType),
    );

    final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
    final success = await notifier.confirmTransaction(widget.transaction.id, payload);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' recorded and confirmed!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm transaction'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _ignore() async {
    final notifier = ref.read(transactionDetectionNotifierProvider.notifier);
    final success = await notifier.ignoreTransaction(widget.transaction.id);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction ignored')),
      );
      context.pop();
    }
  }
}
