import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/widgets/custom_button.dart';

/// Screen 26: AI Recommendation Detail Screen
class AIRecommendationDetailScreen extends ConsumerWidget {
  const AIRecommendationDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'RECOMMENDATION',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.restaurant, color: Colors.orange[700], size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reduce Food Expenses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              // color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'High Priority',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                // color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ANALYSIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Your food expenses increased by 20% this month compared to your average. This represents Rs.3,000 more than typical spending. By implementing meal planning and reducing dining out, you can bring expenses back to normal levels.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ACTION STEPS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionStep('1', 'Plan weekly meals in advance'),
              _buildActionStep('2', 'Cook at home 5 days per week'),
              _buildActionStep('3', 'Limit dining out to once per week'),
              _buildActionStep('4', 'Buy groceries in bulk to save money'),
              const SizedBox(height: 24),
              const Text(
                'POTENTIAL SAVINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: Colors.green[50],
                  border: Border.all(color: Colors.green[700]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.savings, color: Colors.green[700], size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Rs.3,000 per month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        // color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'Mark as Applied', onPressed: () {}),
              const SizedBox(height: 12),
              CustomButton(text: 'Dismiss', variant: ButtonVariant.outline, onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionStep(String number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              // color: Colors.black87,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  // color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
