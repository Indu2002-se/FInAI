import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/ai_provider.dart';
import '../widgets/ai_insight_cards.dart';

/// Screen 24: Expense Forecast Screen — Live Prophet ML Forecast Data
class ExpenseForecastScreen extends ConsumerWidget {
  const ExpenseForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(expenseForecastProvider);

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
          'EXPENSE FORECAST',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: forecastAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Error loading forecast: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(expenseForecastProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (forecast) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ForecastChart(
                    forecast: forecast,
                    onAddExpenses: () {
                      Navigator.pop(context);
                    },
                  ),
                  if (forecast.inferenceSource == 'ML_MODEL') ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(color: Colors.amber.shade700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Prophet ML time-series forecast generated from your spending history and demographic profiles.',
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForecastItem(
      String date, double amount, double lower, double upper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style:
                      const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Range: Rs.${lower.toStringAsFixed(0)} - Rs.${upper.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            'Rs.${amount.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTeal),
          ),
        ],
      ),
    );
  }
}
