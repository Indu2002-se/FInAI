import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';

/// Screen 35: Financial Quiz Screen
class FinancialQuizScreen extends ConsumerStatefulWidget {
  const FinancialQuizScreen({super.key});

  @override
  ConsumerState<FinancialQuizScreen> createState() => _FinancialQuizScreenState();
}

class _FinancialQuizScreenState extends ConsumerState<FinancialQuizScreen> {
  int? _selectedAnswer;

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
          'FINANCIAL QUIZ',
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Question 1 of 5',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'What is the best way to save money?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 32),
              _buildAnswerOption(0, 'Spend everything and save nothing'),
              _buildAnswerOption(1, 'Save a small amount regularly'),
              _buildAnswerOption(2, 'Only save when you have extra money'),
              _buildAnswerOption(3, 'Never think about saving'),
              const Spacer(),
              CustomButton(
                text: 'Next Question',
                onPressed: _selectedAnswer != null ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOption(int index, String text) {
    final isSelected = _selectedAnswer == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAnswer = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue[700]! : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Colors.blue[700] : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
