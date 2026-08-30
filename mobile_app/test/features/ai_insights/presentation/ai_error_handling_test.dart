import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ai_insights/data/models/ai_models.dart';
import 'package:mobile_app/features/ai_insights/presentation/widgets/ai_insight_cards.dart';

void main() {
  group('RiskCard Widget Tests', () {
    testWidgets('displays genuine prediction when inferenceSource == ML_MODEL',
        (WidgetTester tester) async {
      final risk = FinancialRiskModel(
        financialHealthScore: 82.0,
        riskLevel: 'Low Risk',
        riskProbability: 0.15,
        topDriver: 'savings_ratio',
        topDriverReadable: 'Savings Ratio',
        drivers: [],
        inferenceSource: 'ML_MODEL',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiskCard(risk: risk),
          ),
        ),
      );

      expect(find.text('LOW RISK'), findsOneWidget);
      expect(find.text('Probability: 15.0%'), findsOneWidget);
      expect(find.text('Complete Your Profile'), findsNothing);
    });

    testWidgets('displays Complete Profile prompt when inferenceSource == INSUFFICIENT_DATA',
        (WidgetTester tester) async {
      final risk = FinancialRiskModel(
        financialHealthScore: 0.0,
        riskLevel: 'Unknown',
        riskProbability: 0.0,
        topDriver: 'unknown',
        topDriverReadable: 'unknown',
        drivers: [],
        inferenceSource: 'INSUFFICIENT_DATA',
      );

      bool profileClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiskCard(
              risk: risk,
              onCompleteProfile: () {
                profileClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Complete Your Profile'), findsOneWidget);
      expect(
          find.text(
              'Please provide your demographic, income, and expense details to calculate your financial risk accurately.'),
          findsOneWidget);

      await tester.tap(find.text('Complete Profile'));
      expect(profileClicked, isTrue);
    });

    testWidgets('displays Service Temporarily Unavailable when inferenceSource == MODEL_UNAVAILABLE',
        (WidgetTester tester) async {
      final risk = FinancialRiskModel(
        financialHealthScore: 0.0,
        riskLevel: 'Unknown',
        riskProbability: 0.0,
        topDriver: 'unknown',
        topDriverReadable: 'unknown',
        drivers: [],
        inferenceSource: 'MODEL_UNAVAILABLE',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiskCard(risk: risk),
          ),
        ),
      );

      expect(find.text('Service Temporarily Unavailable'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });
  });

  group('ForecastChart Widget Tests', () {
    testWidgets('displays 6-month forecast when inferenceSource == ML_MODEL',
        (WidgetTester tester) async {
      final forecast = ExpenseForecastModel(
        food: [
          ForecastPointModel(
              date: '2026-09-01', predictedAmount: 25000, lowerBound: 20000, upperBound: 30000)
        ],
        nonFood: [
          ForecastPointModel(
              date: '2026-09-01', predictedAmount: 35000, lowerBound: 30000, upperBound: 40000)
        ],
        total: [
          ForecastPointModel(
              date: '2026-09-01', predictedAmount: 60000, lowerBound: 50000, upperBound: 70000)
        ],
        inferenceSource: 'ML_MODEL',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastChart(forecast: forecast),
          ),
        ),
      );

      expect(find.text('Rs.60000'), findsNWidgets(2)); // Card banner and list item
      expect(find.text('Insufficient Expense History'), findsNothing);
    });

    testWidgets('displays Insufficient Expense History prompt when inferenceSource == INSUFFICIENT_HISTORY',
        (WidgetTester tester) async {
      final forecast = ExpenseForecastModel(
        food: [],
        nonFood: [],
        total: [],
        inferenceSource: 'INSUFFICIENT_HISTORY',
      );

      bool addExpensesClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastChart(
              forecast: forecast,
              onAddExpenses: () {
                addExpensesClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Insufficient Expense History'), findsOneWidget);
      expect(
          find.text(
              'At least 3 months of recorded expenses are needed to generate an AI forecast. Please continue logging your monthly expenses.'),
          findsOneWidget);

      await tester.tap(find.text('Add 3 Months of Expenses'));
      expect(addExpensesClicked, isTrue);
    });
  });

  group('RecommendationCard Widget Tests', () {
    testWidgets('displays Rule Fallback disclaimer badge when inferenceSource == RULE_FALLBACK',
        (WidgetTester tester) async {
      final rec = AiRecommendationModel(
        recommendationText: 'Prioritize paying down high-interest balances.',
        category: 'Debt Reduction Plan',
        urgency: 'HIGH',
        actionItems: [],
        inferenceSource: 'RULE_FALLBACK',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: rec),
          ),
        ),
      );

      expect(find.text('Based on general guidelines'), findsOneWidget);
      expect(find.text('DEBT REDUCTION PLAN'), findsOneWidget);
      expect(find.text('Prioritize paying down high-interest balances.'), findsOneWidget);
    });

    testWidgets('does not display Rule Fallback disclaimer badge when inferenceSource == ML_MODEL',
        (WidgetTester tester) async {
      final rec = AiRecommendationModel(
        recommendationText: 'Maximize monthly surplus into index funds.',
        category: 'Maintain & Grow Wealth',
        urgency: 'LOW',
        actionItems: [],
        inferenceSource: 'ML_MODEL',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecommendationCard(recommendation: rec),
          ),
        ),
      );

      expect(find.text('Based on general guidelines'), findsNothing);
      expect(find.text('MAINTAIN & GROW WEALTH'), findsOneWidget);
      expect(find.text('Maximize monthly surplus into index funds.'), findsOneWidget);
    });
  });
}
