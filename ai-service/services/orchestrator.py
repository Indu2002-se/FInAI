import logging
from typing import Dict, Any, List, Optional
from schemas import (
    CombinedAnalysisRequest,
    CombinedAnalysisResponse,
    RiskPredictionResponse,
    ForecastResponse,
    RecommendationResponse,
    RiskExplanation
)
from services.risk_service import RiskService
from services.forecast_service import ForecastService
from services.recommendation_service import RecommendationService

logger = logging.getLogger("finai-ai.orchestrator")

class AIOrchestrator:
    def __init__(self, 
                 risk_service: RiskService,
                 forecast_service: ForecastService,
                 recommendation_service: RecommendationService):
        self.risk_service = risk_service
        self.forecast_service = forecast_service
        self.recommendation_service = recommendation_service

    def analyze(self, request: CombinedAnalysisRequest) -> CombinedAnalysisResponse:
        logger.info(f"Running full AI analysis pipeline for userId={request.userId}")
        
        # 1. Model 1 Risk & Financial Health Score + SHAP Explanation
        risk_result: RiskPredictionResponse = self.risk_service.predict(request.features)
        
        # 2. Model 2 Expense Forecast
        forecast_result: ForecastResponse = self.forecast_service.forecast(
            history=request.expenseHistory or [],
            forecast_months=request.forecastMonths or 6
        )

        # 3. Model 3 Personalized Recommendation
        top_driver = risk_result.explanation.topDriver if risk_result.explanation else "expense_to_income_ratio"
        rec_result: RecommendationResponse = self.recommendation_service.generate(
            risk_level=risk_result.riskLevel,
            health_score=risk_result.financialHealthScore,
            top_driver=top_driver,
            features=request.features
        )

        return CombinedAnalysisResponse(
            risk=risk_result,
            explanation=risk_result.explanation,
            forecast=forecast_result,
            recommendation=rec_result
        )
