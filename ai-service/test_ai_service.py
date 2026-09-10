import os
import unittest
import pytest
from fastapi.testclient import TestClient
from main import app
from services.risk_service import RiskService
from services.forecast_service import ForecastService
from services.recommendation_service import RecommendationService
from schemas import (
    MonthlyExpenseRecord,
    RiskPredictionResponse,
    ForecastResponse,
    RecommendationResponse,
    CombinedAnalysisResponse
)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.environ.get("MODELS_DIR", os.path.join(BASE_DIR, "models"))
if not os.path.exists(MODELS_DIR):
    alt_dir = os.path.join(BASE_DIR, "..", "..", "FINAL_MODEL_ARTIFACTS")
    if os.path.exists(alt_dir):
        MODELS_DIR = alt_dir

def get_valid_41_features():
    cols = [
        "age", "gender", "education", "marital_status", "household_size_f",
        "employment_income", "other_income", "windfall_income", "agri_income",
        "non_agri_income", "transfer_income", "total_income", "food_expenditure",
        "nonfood_expenditure", "total_expenditure", "expense_to_income_ratio",
        "financial_surplus", "savings_ratio", "per_capita_income", "employment_capacity",
        "debt_amount", "debt_records", "debt_sources", "debt_to_income_ratio",
        "credit_card_debt", "has_credit_card_debt", "has_creditmix_match",
        "credit_score", "credit_clv", "credit_fraud_txn",
        "cc_utilization_ratio", "cc_late_payments", "cc_credit_lines",
        "cc_debt_to_income_ratio", "cc_total_spend_last_year", "cc_avg_txn_amount",
        "cc_total_txns", "cc_tenure_years", "vehicle_ownership",
        "instalment_goods_flag", "instalment_amount"
    ]
    feats = {col: 0.0 for col in cols}
    feats.update({
        "age": 40.0, "gender": 1.0, "education": 10.0, "marital_status": 1.0, "household_size_f": 4.0,
        "employment_income": 120000.0, "total_income": 120000.0,
        "food_expenditure": 25000.0, "nonfood_expenditure": 35000.0, "total_expenditure": 60000.0,
        "expense_to_income_ratio": 0.50, "financial_surplus": 60000.0, "savings_ratio": 0.50,
        "per_capita_income": 30000.0, "employment_capacity": 1.0,
        "debt_amount": 0.0, "debt_records": 0.0, "debt_sources": 0.0, "debt_to_income_ratio": 0.0,
        "credit_score": 740.0
    })
    return feats

def get_valid_expense_history(months=6):
    return [
        MonthlyExpenseRecord(date=f"2025-{m:02d}-01", food=25000.0, nonFood=35000.0, total=60000.0)
        for m in range(1, months + 1)
    ]

# ==================== Health Test ====================

def test_health():
    with TestClient(app) as c:
        response = c.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"

# ==================== Task 7 & 8: RiskService Tests ====================

def test_model1_artifact_loading_and_features():
    risk_svc = RiskService(MODELS_DIR)
    assert risk_svc.model is not None, "Model 1 artifact must load successfully"
    assert len(risk_svc.feature_cols) == 41, "Model 1 must have exactly 41 feature columns"
    assert "credit_defaulted" not in risk_svc.feature_cols, "credit_defaulted must be dropped due to target leakage"
    assert "expense_to_income_ratio" in risk_svc.feature_cols
    assert "debt_to_income_ratio" in risk_svc.feature_cols
    assert "savings_ratio" in risk_svc.feature_cols
    assert len(risk_svc.label_map) == 3, "Model 1 must have 3 risk classes"

def test_model1_missing_artifact_sets_none(tmp_path):
    empty_svc = RiskService(str(tmp_path))
    assert empty_svc.model is None
    res = empty_svc.predict(get_valid_41_features())
    assert res.inference_source == "MODEL_UNAVAILABLE"
    assert res.riskLevel in ["Unknown", "Model Unavailable"]

def test_model1_valid_41_features_prediction():
    risk_svc = RiskService(MODELS_DIR)
    feats = get_valid_41_features()
    result = risk_svc.predict(feats)
    assert result.inference_source == "ML_MODEL"
    assert result.riskLevel in ["Low Risk", "Medium Risk", "High Risk"]
    assert 0.0 <= result.riskProbability <= 1.0
    assert 0.0 <= result.financialHealthScore <= 100.0
    assert result.explanation is not None
    assert len(result.explanation.topDriver) > 0

def test_model1_invalid_feature_length_fails():
    risk_svc = RiskService(MODELS_DIR)
    partial_features = {"age": 40, "total_income": 120000.0}  # Only 2 features instead of 41
    result = risk_svc.predict(partial_features)
    assert result.inference_source == "INVALID_FEATURES"
    assert result.riskLevel == "Invalid Features"
    assert result.explanation is not None

# ==================== Task 9 & 10: ForecastService Tests ====================

def test_model2_prophet_loading():
    forecast_svc = ForecastService(MODELS_DIR)
    assert forecast_svc.food_model is not None
    assert forecast_svc.nonfood_model is not None
    assert forecast_svc.total_model is not None

def test_model2_missing_artifacts_sets_none(tmp_path):
    empty_svc = ForecastService(str(tmp_path))
    assert empty_svc.food_model is None
    res = empty_svc.forecast(get_valid_expense_history(6), forecast_months=6)
    assert res.inference_source == "MODEL_UNAVAILABLE"
    assert len(res.total) == 0

def test_model2_forecast_valid_history():
    forecast_svc = ForecastService(MODELS_DIR)
    history = get_valid_expense_history(6)
    fc = forecast_svc.forecast(history=history, forecast_months=6)
    assert fc.inference_source == "ML_MODEL"
    assert len(fc.total) == 6
    assert len(fc.food) == 6
    assert len(fc.nonFood) == 6
    for i in range(6):
        assert fc.total[i].predictedAmount >= 0.0
        assert fc.food[i].predictedAmount >= 0.0
        assert fc.nonFood[i].predictedAmount >= 0.0

def test_model2_forecast_insufficient_history():
    forecast_svc = ForecastService(MODELS_DIR)
    short_history = [
        MonthlyExpenseRecord(date="2026-01-01", food=25000, nonFood=35000, total=60000),
        MonthlyExpenseRecord(date="2026-02-01", food=26000, nonFood=36000, total=62000)
    ]
    fc = forecast_svc.forecast(history=short_history, forecast_months=6)
    assert fc.inference_source == "INSUFFICIENT_HISTORY"
    assert len(fc.total) == 0

# ==================== Task 11 & 12: RecommendationService Tests ====================

def test_model3_artifact_loading():
    rec_svc = RecommendationService(MODELS_DIR)
    assert rec_svc.model is not None
    assert len(rec_svc.feature_cols) == 41
    assert "credit_defaulted" not in rec_svc.feature_cols
    assert len(rec_svc.label_map) == 5
    assert "debt_to_income_high" in rec_svc.thresholds

def test_model3_missing_artifacts_sets_none(tmp_path):
    empty_svc = RecommendationService(str(tmp_path))
    assert empty_svc.model is None
    res = empty_svc.generate(features=None)
    assert res.inference_source == "RULE_FALLBACK"

def test_model3_ml_prediction():
    rec_svc = RecommendationService(MODELS_DIR)
    feats = get_valid_41_features()
    res = rec_svc.generate(
        risk_level="Low Risk",
        health_score=85.0,
        top_driver="savings_ratio",
        features=feats
    )
    assert res.inference_source == "ML_MODEL"
    assert len(res.category) > 0
    assert len(res.actionItems) > 0

def test_model3_rule_fallback_when_model_disabled():
    rec_svc = RecommendationService(MODELS_DIR)
    rec_svc.model = None  # disable model
    feats = get_valid_41_features()
    feats["debt_to_income_ratio"] = 0.5  # High debt
    res = rec_svc.generate(
        risk_level="High Risk",
        health_score=40.0,
        top_driver="debt_to_income_ratio",
        features=feats
    )
    assert res.inference_source == "RULE_FALLBACK"
    assert res.category == "Debt Reduction Plan"
    assert len(res.actionItems) > 0

# ==================== Task 13: Response Schemas & API Tests ====================

def test_api_risk_predict_valid_features():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": get_valid_41_features()
        }
        response = c.post("/api/v1/ai/risk/predict", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["inference_source"] == "ML_MODEL"
        assert "financialHealthScore" in data
        assert "riskLevel" in data

def test_api_risk_predict_invalid_features():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": {"age": 25}
        }
        response = c.post("/api/v1/ai/risk/predict", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["inference_source"] == "INVALID_FEATURES"

def test_api_expense_forecast_valid():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "history": [r.model_dump() for r in get_valid_expense_history(4)],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/expense/forecast", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["inference_source"] == "ML_MODEL"
        assert len(data["total"]) == 6

def test_api_expense_forecast_insufficient():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "history": [
                {"date": "2026-01-01", "food": 25000, "nonFood": 20000, "total": 45000}
            ],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/expense/forecast", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["inference_source"] == "INSUFFICIENT_HISTORY"
        assert len(data["total"]) == 0

def test_api_recommendation_generate():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "riskLevel": "Low Risk",
            "financialHealthScore": 85.0,
            "topDriver": "savings_ratio",
            "features": get_valid_41_features()
        }
        response = c.post("/api/v1/ai/recommendation/generate", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["inference_source"] == "ML_MODEL"
        assert "category" in data
        assert len(data["actionItems"]) > 0

def test_api_combined_analyze():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": get_valid_41_features(),
            "expenseHistory": [r.model_dump() for r in get_valid_expense_history(4)],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/analyze", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert data["risk"]["inference_source"] == "ML_MODEL"
        assert data["forecast"]["inference_source"] == "ML_MODEL"
        assert data["recommendation"]["inference_source"] == "ML_MODEL"
        assert len(data["forecast"]["total"]) == 6

def test_api_savings_plan_generate_success(monkeypatch):
    monkeypatch.setattr("services.gemini_plan_service.GeminiSavingsPlanService._call_gemini_api", lambda *args, **kwargs: "Mock AI Strategy Report")
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

def test_api_savings_plan_missing_income_fails():
    with TestClient(app) as c:
        payload = {
            "goalTitle": "Emergency Fund",
            "targetAmount": 300000.0,
            "currentAmount": 50000.0,
            "targetMonths": 6
            # monthlyIncome and monthlyExpense deliberately omitted
        }
        response = c.post("/api/v1/ai/savings-plan/generate", json=payload)
        assert response.status_code == 400

def test_input_sensitivity_user_a_vs_user_b():
    """Verify that different users produce sensitive, distinct predictions reflecting real data."""
    risk_svc = RiskService(MODELS_DIR)

    # User A: High income, low expenditure, no debt, strong surplus
    user_a = get_valid_41_features()
    user_a.update({
        "total_income": 200000.0,
        "employment_income": 200000.0,
        "total_expenditure": 50000.0,
        "food_expenditure": 20000.0,
        "nonfood_expenditure": 30000.0,
        "expense_to_income_ratio": 0.25,
        "financial_surplus": 150000.0,
        "savings_ratio": 0.75,
        "debt_amount": 0.0,
        "debt_to_income_ratio": 0.0,
        "credit_score": 780.0
    })

    # User B: Low income, high expenditure, high debt, negative surplus
    user_b = get_valid_41_features()
    user_b.update({
        "total_income": 40000.0,
        "employment_income": 40000.0,
        "total_expenditure": 65000.0,
        "food_expenditure": 25000.0,
        "nonfood_expenditure": 40000.0,
        "expense_to_income_ratio": 1.625,
        "financial_surplus": -25000.0,
        "savings_ratio": -0.625,
        "debt_amount": 180000.0,
        "debt_to_income_ratio": 4.5,
        "credit_score": 520.0
    })

    res_a = risk_svc.predict(user_a)
    res_b = risk_svc.predict(user_b)

    assert res_a.inference_source == "ML_MODEL"
    assert res_b.inference_source == "ML_MODEL"
    assert res_a.financialHealthScore > res_b.financialHealthScore, (
        f"User A score ({res_a.financialHealthScore}) should exceed User B ({res_b.financialHealthScore})"
    )
    assert res_a.riskProbability < res_b.riskProbability, (
        f"User A risk prob ({res_a.riskProbability}) should be lower than User B ({res_b.riskProbability})"
    )

if __name__ == "__main__":
    pytest.main([__file__, "-v"])


