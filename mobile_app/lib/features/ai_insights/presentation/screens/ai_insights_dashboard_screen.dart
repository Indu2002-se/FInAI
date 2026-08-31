import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/ai_provider.dart';

/// Screen 21: AI Insights Dashboard — Live backend-driven insights with navigation
class AIInsightsDashboardScreen extends ConsumerWidget {
  const AIInsightsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiAsync = ref.watch(latestAiAnalysisProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back, size: 16),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text(
          'AI INSIGHTS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh Insights',
            onPressed: () {
              ref.invalidate(latestAiAnalysisProvider);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: aiAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading AI Insights...',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load AI Insights',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(latestAiAnalysisProvider),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (aiData) {
            final risk = aiData.risk;
            final forecast = aiData.forecast;
            final recommendation = aiData.recommendation;

            // 1. Health Score formatting
            final healthScore = risk?.financialHealthScore ?? 75.0;
            final healthScoreStr = '${healthScore.round()} / 100';
            final healthColor = healthScore >= 75
                ? AppColors.success
                : healthScore >= 50
                    ? AppColors.warning
                    : AppColors.error;

            // 2. Risk Level formatting
            final riskLevel = risk?.riskLevel ?? 'Low Risk';
            final riskColor = riskLevel.toLowerCase().contains('high')
                ? AppColors.error
                : riskLevel.toLowerCase().contains('medium')
                    ? AppColors.warning
                    : AppColors.success;

            // 3. Forecast formatting
            final nextMonthForecast = (forecast != null && forecast.total.isNotEmpty)
                ? 'Next month: Rs.${forecast.total.first.predictedAmount.toStringAsFixed(0)}'
                : '6-month expense forecast available';

            // 4. Recommendation formatting
            final recCategory = recommendation?.category ?? 'Personalized Advice';
            final actionCount = recommendation?.actionItems.length ?? 0;
            final recSubtitle = actionCount > 0
                ? '$recCategory • $actionCount action items'
                : recCategory;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                InfoCard(
                  title: 'Financial Health Score',
                  subtitle: healthScoreStr,
                  leading: Icon(Icons.favorite, color: healthColor, size: 28),
                  onTap: () {
                    context.push(RouteNames.financialHealth);
                  },
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Financial Risk Prediction',
                  subtitle: riskLevel,
                  leading: Icon(Icons.warning_amber, color: riskColor, size: 28),
                  onTap: () {
                    context.push(RouteNames.financialRisk);
                  },
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Expense Forecast',
                  subtitle: nextMonthForecast,
                  leading: const Icon(Icons.trending_up, color: Colors.blue, size: 28),
                  onTap: () {
                    context.push(RouteNames.expenseForecast);
                  },
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'AI Recommendations',
                  subtitle: recSubtitle,
                  leading: const Icon(Icons.lightbulb, color: Colors.amber, size: 28),
                  onTap: () {
                    context.push(RouteNames.aiRecommendations);
                  },
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }
}

