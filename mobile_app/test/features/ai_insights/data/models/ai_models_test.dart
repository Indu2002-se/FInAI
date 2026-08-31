import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/ai_insights/data/models/ai_models.dart';

void main() {
  group('FinancialRiskModel', () {
    test('fromJson parses financial risk and drivers correctly', () {
      final json = {
        'financialHealthScore': 82.5,
        'riskLevel': 'Low Risk',
        'riskProbability': 0.18,
        'topDriver': 'expense_to_income_ratio',
        'topDriverReadable': 'Expense-to-Income Ratio',
        'drivers': [
          {
            'feature': 'expense_to_income_ratio',
            'impact': 0.65,
            'direction': 'decreases_risk',
            'readableName': 'Expense-to-Income Ratio',
            'description': 'Ratio of routine living costs to total earnings',
          },
        ],
      };

      final model = FinancialRiskModel.fromJson(json);

      expect(model.financialHealthScore, 82.5);
      expect(model.riskLevel, 'Low Risk');
      expect(model.riskProbability, 0.18);
      expect(model.topDriver, 'expense_to_income_ratio');
      expect(model.topDriverReadable, 'Expense-to-Income Ratio');
      expect(model.drivers.length, 1);
      expect(model.drivers.first.feature, 'expense_to_income_ratio');
      expect(model.drivers.first.impact, 0.65);
    });
  });

  group('ExpenseForecastModel', () {
    test('fromJson parses food, nonFood, and total forecasts correctly', () {
      final json = {
        'food': [
          {
            'date': '2026-09-01',
            'predictedAmount': 25000.0,
            'lowerBound': 23000.0,
            'upperBound': 27000.0,
          }
        ],
        'nonFood': [
          {
            'date': '2026-09-01',
            'predictedAmount': 40000.0,
            'lowerBound': 36000.0,
            'upperBound': 44000.0,
          }
        ],
        'total': [
          {
            'date': '2026-09-01',
            'predictedAmount': 65000.0,
            'lowerBound': 59000.0,
            'upperBound': 71000.0,
          }
        ],
      };

      final model = ExpenseForecastModel.fromJson(json);

      expect(model.food.length, 1);
      expect(model.nonFood.length, 1);
      expect(model.total.length, 1);
      expect(model.total.first.predictedAmount, 65000.0);
      expect(model.total.first.date, '2026-09-01');
    });
  });

  group('AiRecommendationModel', () {
    test('fromJson parses recommendation text, category, and action items', () {
      final json = {
        'recommendationText': 'Increase monthly automated savings transfer to grow rainy-day reserves.',
        'category': 'Expense Optimization',
        'urgency': 'MEDIUM',
        'actionItems': [
          'Review discretionary subscriptions',
          'Automate 10% transfer on payday',
        ],
      };

      final model = AiRecommendationModel.fromJson(json);

      expect(model.recommendationText, contains('Increase monthly automated savings'));
      expect(model.category, 'Expense Optimization');
      expect(model.urgency, 'MEDIUM');
      expect(model.actionItems.length, 2);
      expect(model.actionItems.first.step, 'Review discretionary subscriptions');
    });
  });

  group('SavingsPlanModel', () {
    test('fromJson parses complete savings plan response', () {
      final json = {
        'goalTitle': 'Emergency Fund',
        'targetAmount': 150000.0,
        'currentAmount': 30000.0,
        'targetMonths': 6,
        'monthlyRequiredSavings': 20000.0,
        'monthlySurplus': 25000.0,
        'feasibilityScore': 85.0,
        'feasibilityStatus': 'Highly Achievable',
        'difficultyLevel': 'LOW',
        'categoryReductions': [
          {
            'category': 'Food & Dining',
            'suggestedCut': 3000.0,
            'action': 'Reduce dining out frequency',
          }
        ],
        'milestones': [
          {
            'month': 1,
            'targetAccumulated': 50000.0,
            'completionPercentage': 33.3,
          }
        ],
        'aiStrategyReport': 'Detailed Roadmap Report',
      };

      final model = SavingsPlanModel.fromJson(json);

      expect(model.goalTitle, 'Emergency Fund');
      expect(model.targetAmount, 150000.0);
      expect(model.targetMonths, 6);
      expect(model.monthlyRequiredSavings, 20000.0);
      expect(model.feasibilityScore, 85.0);
      expect(model.feasibilityStatus, 'Highly Achievable');
      expect(model.difficultyLevel, 'LOW');
      expect(model.categoryReductions.length, 1);
      expect(model.milestones.length, 1);
      expect(model.milestones.first.targetAccumulated, 50000.0);
      expect(model.aiStrategyReport, 'Detailed Roadmap Report');
    });
  });
}
