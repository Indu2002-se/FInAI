import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/ai_provider.dart';

/// Screen 23: Financial Risk Prediction Screen — Live data from AI Service
class FinancialRiskPredictionScreen extends ConsumerWidget {
  const FinancialRiskPredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riskAsync = ref.watch(riskPredictionProvider);

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
          'FINANCIAL RISK',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: riskAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Error loading risk data: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(riskPredictionProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (risk) {
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

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SHAP AI RISK DRIVERS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (risk.drivers.isEmpty)
                    _buildRiskFactor(
                      risk.topDriverReadable,
                      risk.riskLevel,
                      'Primary variable influencing overall prediction model.',
                      color,
                    )
                  else
                    ...risk.drivers.map((d) {
                      final isInc = d.direction == 'increases_risk';
                      final drvColor =
                          isInc ? AppColors.error : AppColors.success;
                      final level = isInc ? 'Increases Risk' : 'Protective Factor';
                      final title = d.readableName.isNotEmpty
                          ? d.readableName
                          : d.feature;
                      return _buildRiskFactor(
                        title,
                        level,
                        d.description.isNotEmpty
                            ? d.description
                            : 'Impact coefficient: ${(d.impact * 100).toStringAsFixed(1)}%',
                        drvColor,
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRiskFactor(
      String title, String level, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
