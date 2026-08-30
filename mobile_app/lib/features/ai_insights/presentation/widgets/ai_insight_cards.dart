import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/ai_models.dart';

/// RiskCard: Displays financial risk prediction or appropriate error/guidance state
class RiskCard extends StatelessWidget {
  final FinancialRiskModel risk;
  final VoidCallback? onCompleteProfile;

  const RiskCard({
    super.key,
    required this.risk,
    this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final source = risk.inferenceSource;

    if (source == 'INSUFFICIENT_DATA') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade700, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.person_add_alt_1_outlined, color: Colors.amber.shade800, size: 48),
            const SizedBox(height: 12),
            Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your demographic, income, and expense details to calculate your financial risk accurately.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            if (onCompleteProfile != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onCompleteProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Complete Profile'),
              ),
            ],
          ],
        ),
      );
    }

    if (source == 'MODEL_UNAVAILABLE') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey.shade700, size: 44),
            const SizedBox(height: 10),
            Text(
              'Service Temporarily Unavailable',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI risk prediction models are currently offline. Please check back shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (source == 'INVALID_FEATURES') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 44),
            const SizedBox(height: 10),
            Text(
              'Financial Data Format Error',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Some financial features could not be validated. Please review your income, debt, and expense entries.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    // Default ML_MODEL view
    final isHigh = risk.riskLevel.toLowerCase().contains('high');
    final isMedium = risk.riskLevel.toLowerCase().contains('medium');
    final color = isHigh
        ? AppColors.error
        : isMedium
            ? AppColors.warning
            : AppColors.success;

    final statusSubtitle = isHigh
        ? 'High probability of financial distress detected.'
        : isMedium
            ? 'Moderate risk — potential budget or debt pressure.'
            : 'Your financial situation is stable.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            isHigh
                ? Icons.warning_amber_rounded
                : isMedium
                    ? Icons.info_outline
                    : Icons.check_circle,
            color: color,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            risk.riskLevel.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Text(
            'Probability: ${(risk.riskProbability * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ForecastChart: Displays 6-month expense forecast points or error/guidance state
class ForecastChart extends StatelessWidget {
  final ExpenseForecastModel forecast;
  final VoidCallback? onAddExpenses;

  const ForecastChart({
    super.key,
    required this.forecast,
    this.onAddExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final source = forecast.inferenceSource;

    if (source == 'INSUFFICIENT_HISTORY') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue.shade400, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off, color: Colors.blue.shade800, size: 48),
            const SizedBox(height: 12),
            Text(
              'Insufficient Expense History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'At least 3 months of recorded expenses are needed to generate an AI forecast. Please continue logging your monthly expenses.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            if (onAddExpenses != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddExpenses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add 3 Months of Expenses'),
              ),
            ],
          ],
        ),
      );
    }

    if (source == 'MODEL_UNAVAILABLE') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey.shade700, size: 44),
            const SizedBox(height: 10),
            Text(
              'Forecast Service Unavailable',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prophet forecasting models are currently offline. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    if (source != 'ML_MODEL') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
            const SizedBox(height: 8),
            Text(
              'Unable to Generate Forecast ($source)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade900,
              ),
            ),
          ],
        ),
      );
    }

    // Default ML_MODEL view
    final totalList = forecast.total;
    final nextMonth = totalList.isNotEmpty ? totalList.first : null;
    final nextMonthAmount = nextMonth?.predictedAmount ?? 0.0;
    final nextMonthDate = nextMonth?.date ?? 'Next Month';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade700, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                nextMonthDate.length >= 7 ? nextMonthDate.substring(0, 7) : nextMonthDate,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rs.${nextMonthAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Next Month Predicted Total',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '6-MONTH PROJECTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        if (totalList.isEmpty)
          const Text('No forecast points available.')
        else
          ...totalList.map((pt) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pt.date.length >= 7 ? pt.date.substring(0, 7) : pt.date,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      'Rs.${pt.predictedAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}

/// RecommendationCard: Displays AI recommendations with disclaimer badge for rule fallback
class RecommendationCard extends StatelessWidget {
  final AiRecommendationModel recommendation;
  final VoidCallback? onCompleteProfile;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    final source = recommendation.inferenceSource;

    if (source == 'INSUFFICIENT_DATA') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade600, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(Icons.edit_note, color: Colors.amber.shade800, size: 40),
            const SizedBox(height: 8),
            Text(
              'Complete Your Profile',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Complete your profile with income and expenses to unlock tailored AI recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            if (onCompleteProfile != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onCompleteProfile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                child: const Text('Complete Profile', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      );
    }

    if (source == 'MODEL_UNAVAILABLE') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey.shade700, size: 40),
            const SizedBox(height: 8),
            Text(
              'Recommendation Service Unavailable',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI recommendation service is temporarily unavailable.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final isRuleFallback = source == 'RULE_FALLBACK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRuleFallback)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on general guidelines',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isRuleFallback
                ? LinearGradient(
                    colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isRuleFallback ? Icons.rule : Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    recommendation.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation.recommendationText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
