from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    with TestClient(app) as c:
        response = c.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"

def test_risk_predict():
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

def test_expense_forecast():
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

def test_recommendation_generate():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "riskLevel": "Low Risk",
            "financialHealthScore": 85.0,
            "topDriver": "savings_ratio"
        }
        response = c.post("/api/v1/ai/recommendation/generate", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "category" in data
        assert "recommendation" in data
        assert len(data["actionItems"]) > 0

def test_combined_analyze():
    with TestClient(app) as c:
        payload = {
            "userId": 1,
            "features": {
                "expense_to_income_ratio": 0.65,
                "total_income": 100000.0,
                "total_expenditure": 65000.0,
                "debt_to_income_ratio": 0.2
            },
            "expenseHistory": [],
            "forecastMonths": 6
        }
        response = c.post("/api/v1/ai/analyze", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "risk" in data
        assert "explanation" in data
        assert "forecast" in data
        assert "recommendation" in data

def test_savings_plan_generate():
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
