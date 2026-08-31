import os
import unittest
from fastapi.testclient import TestClient
from main import app
from services.risk_service import RiskService
from services.forecast_service import ForecastService
from services.recommendation_service import RecommendationService
from schemas import MonthlyExpenseRecord

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.environ.get("MODELS_DIR", os.path.join(BASE_DIR, "models"))
if not os.path.exists(MODELS_DIR):
    alt_dir = os.path.join(BASE_DIR, "..", "..", "FINAL_MODEL_ARTIFACTS")
    if os.path.exists(alt_dir):
        MODELS_DIR = alt_dir

# ==================== Health Test ====================

def test_health():
    with TestClient(app) as c:
        response = c.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"

# ==================== Model 1 Tests ====================

def test_model1_artifact_loading_and_features():
    risk_svc = RiskService(MODELS_DIR)
    assert risk_svc.model is not None, "Model 1 artifact must load successfully"
    assert len(risk_svc.feature_cols) == 42, "Model 1 must have exactly 42 feature columns"
    assert "expense_to_income_ratio" in risk_svc.feature_cols
    assert "debt_to_income_ratio" in risk_svc.feature_cols
    assert "savings_ratio" in risk_svc.feature_cols
    assert len(risk_svc.label_map) == 3, "Model 1 must have 3 risk classes"

def test_model1_prediction_and_shap():
    risk_svc = RiskService(MODELS_DIR)
    sample_features = {
        "age": 40,
        "gender": 1,
        "education": 10,
        "marital_status": 1,
        "household_size_f": 4,
        "total_income": 120000.0,
        "food_expenditure": 25000.0,
        "nonfood_expenditure": 35000.0,
        "total_expenditure": 60000.0,
        "expense_to_income_ratio": 0.50,
        "financial_surplus": 60000.0,
        "savings_ratio": 0.50,
        "debt_amount": 0.0,
        "debt_to_income_ratio": 0.0,
        "credit_score": 740
    }
    result = risk_svc.predict(sample_features)
    assert result.riskLevel in ["Low Risk", "Medium Risk", "High Risk"]
    assert 0.0 <= result.riskProbability <= 1.0
    assert 0.0 <= result.financialHealthScore <= 100.0
    assert result.explanation is not None
    assert len(result.explanation.topDriver) > 0
    assert len(result.explanation.drivers) > 0
    for d in result.explanation.drivers:
        assert d.direction in ["increases_risk", "decreases_risk"]
        assert isinstance(d.impact, float)

# ==================== Model 2 Tests ====================

def test_model2_prophet_loading_and_multi_horizon():
    forecast_svc = ForecastService(MODELS_DIR)
    for horizon in [3, 6, 12]:
        history = [
            MonthlyExpenseRecord(date="2026-01-01", food=25000, nonFood=35000, total=60000),
            MonthlyExpenseRecord(date="2026-02-01", food=26000, nonFood=36000, total=62000),
        ]
        fc = forecast_svc.forecast(history=history, forecast_months=horizon)
        assert len(fc.total) == horizon, f"Forecast must have {horizon} points"
        assert len(fc.food) == horizon
        assert len(fc.nonFood) == horizon
        assert fc.forecastMonths == horizon

        # Verify sequential dates and non-negativity
        for i in range(horizon):
            assert fc.total[i].predictedAmount >= 0.0, "Total forecast must be non-negative"
            assert fc.food[i].predictedAmount >= 0.0, "Food forecast must be non-negative"
            assert fc.nonFood[i].predictedAmount >= 0.0, "Non-food forecast must be non-negative"
            assert fc.total[i].lowerBound >= 0.0
            assert fc.total[i].upperBound >= fc.total[i].predictedAmount

def test_model2_fallback_when_model_disabled():
    forecast_svc = ForecastService(MODELS_DIR)
    # Simulate disabled / missing Prophet models
    forecast_svc.food_model = None
    forecast_svc.nonfood_model = None
    forecast_svc.total_model = None

    history = [MonthlyExpenseRecord(date="2026-01-01", food=20000, nonFood=30000, total=50000)]
    fc = forecast_svc.forecast(history=history, forecast_months=6)
    assert len(fc.total) == 6
    assert all(pt.predictedAmount > 0 for pt in fc.total)

# ==================== Model 3 Tests ====================

def test_model3_artifact_loading_and_features():
    rec_svc = RecommendationService(MODELS_DIR)
    assert rec_svc.model is not None, "Model 3 XGBoost artifact must load successfully"
    assert len(rec_svc.feature_cols) == 42, "Model 3 must use all 42 features"
    assert len(rec_svc.label_map) == 5, "Model 3 must map to 5 recommendation categories"

def test_model3_real_xgboost_inference():
    rec_svc = RecommendationService(MODELS_DIR)
    valid_categories = {
        "Build Emergency Savings",
        "Debt Reduction Plan",
        "Expense Optimization",
        "Increase Income / Employment Support",
        "Maintain & Grow Wealth"
    }

    # Case A: Low risk, healthy profile -> Real ML inference
    features_wealth = {
        "age": 45, "gender": 1, "education": 13, "marital_status": 2, "household_size_f": 3,
        "total_income": 250000.0, "employment_income": 250000.0,
        "food_expenditure": 30000.0, "nonfood_expenditure": 40000.0, "total_expenditure": 70000.0,
        "expense_to_income_ratio": 0.28, "financial_surplus": 180000.0, "savings_ratio": 0.72,
        "per_capita_income": 83333.0, "debt_amount": 0.0, "debt_to_income_ratio": 0.0, "credit_score": 780
    }
    rec_a = rec_svc.generate(risk_level="Low Risk", health_score=92.0, top_driver="savings_ratio", features=features_wealth)
    assert rec_a.category in valid_categories
    assert len(rec_a.recommendation) > 0
    assert len(rec_a.actionItems) > 0

    # Case B: Rule fallback when features are not provided
    rec_fallback = rec_svc.generate(risk_level="High Risk", health_score=35.0, top_driver="debt_to_income_ratio", features=None)
    assert rec_fallback.category == "Debt Reduction Plan"
    assert len(rec_fallback.actionItems) > 0

# ==================== Integration API Tests ====================

def test_api_risk_predict():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": {
                "age": 35,
                "total_income": 120000.0,
                "total_expenditure": 60000.0,
                "expense_to_income_ratio": 0.5,
                "financial_surplus": 60000.0,
                "debt_amount": 0.0,
                "debt_to_income_ratio": 0.0,
                "savings_ratio": 0.3
            }
        }
        response = c.post("/api/v1/ai/risk/predict", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "financialHealthScore" in data
        assert "riskLevel" in data
        assert "riskProbability" in data
        assert "explanation" in data

def test_api_expense_forecast():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "history": [
                {"date": "2026-01-01", "food": 25000, "nonFood": 20000, "total": 45000},
                {"date": "2026-02-01", "food": 26000, "nonFood": 21000, "total": 47000}
            ],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/expense/forecast", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert len(data["total"]) == 6
        assert len(data["food"]) == 6
        assert len(data["nonFood"]) == 6

def test_api_recommendation_generate():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "riskLevel": "Low Risk",
            "financialHealthScore": 85.0,
            "topDriver": "savings_ratio",
            "features": {
                "total_income": 150000.0,
                "total_expenditure": 50000.0,
                "expense_to_income_ratio": 0.33,
                "financial_surplus": 100000.0,
                "debt_amount": 0.0,
                "debt_to_income_ratio": 0.0
            }
        }
        response = c.post("/api/v1/ai/recommendation/generate", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "category" in data
        assert "recommendation" in data
        assert len(data["actionItems"]) > 0

def test_api_combined_analyze():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": {
                "expense_to_income_ratio": 0.65,
                "total_income": 100000.0,
                "total_expenditure": 65000.0,
                "debt_to_income_ratio": 0.2
            },
            "expenseHistory": [
                {"date": "2026-01-01", "food": 20000, "nonFood": 35000, "total": 55000}
            ],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/analyze", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "risk" in data
        assert "explanation" in data
        assert "forecast" in data
        assert "recommendation" in data

def test_api_savings_plan_generate():
    with TestClient(app) as c:
        payload = {
            "goalTitle": "Emergency Fund",
            "targetAmount": 300000.0,
            "currentAmount": 50000.0,
            "targetMonths": 6,
            "monthlyIncome": 120000.0,
            "monthlyExpense": 70000.0
        }
        response = c.post("/api/v1/ai/savings-plan/generate", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["goalTitle"] == "Emergency Fund"
        assert data["monthlyRequiredSavings"] > 0
        assert "feasibilityScore" in data
        assert "aiStrategyReport" in data
        assert len(data["milestones"]) == 6

if __name__ == "__main__":
    tests = [
        test_health,
        test_model1_artifact_loading_and_features,
        test_model1_prediction_and_shap,
        test_model2_prophet_loading_and_multi_horizon,
        test_model2_fallback_when_model_disabled,
        test_model3_artifact_loading_and_features,
        test_model3_real_xgboost_inference,
        test_api_risk_predict,
        test_api_expense_forecast,
        test_api_recommendation_generate,
        test_api_combined_analyze,
        test_api_savings_plan_generate
    ]
    print(f"Running {len(tests)} test cases...")
    passed = 0
    for t in tests:
        try:
            t()
            print(f"  [PASS] {t.__name__}")
            passed += 1
        except Exception as e:
            print(f"  [FAIL] {t.__name__}: {e}")
            raise
    print(f"\n==================== {passed}/{len(tests)} TESTS PASSED SUCCESSFULLY! ====================")


