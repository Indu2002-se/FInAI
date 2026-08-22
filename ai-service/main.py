import os
import logging
from contextlib import asynccontextmanager

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from schemas import (
    RiskPredictionRequest,
    RiskPredictionResponse,
    ForecastRequest,
    ForecastResponse,
    RecommendationRequest,
    RecommendationResponse,
    CombinedAnalysisRequest,
    CombinedAnalysisResponse,
    SavingsPlanRequest,
    SavingsPlanResponse
)
from services.risk_service import RiskService
from services.forecast_service import ForecastService
from services.recommendation_service import RecommendationService
from services.orchestrator import AIOrchestrator
from services.gemini_plan_service import GeminiSavingsPlanService

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("finai-ai")

# Services container
services = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: locate model artifacts and initialize services
    base_dir = os.path.dirname(os.path.abspath(__file__))
    models_dir = os.environ.get("MODELS_DIR", os.path.join(base_dir, "models"))

    if not os.path.exists(models_dir):
        alt_dir = os.path.join(base_dir, "..", "..", "FINAL_MODEL_ARTIFACTS")
        if os.path.exists(alt_dir):
            models_dir = alt_dir

    logger.info(f"Initializing AI services with models directory: {models_dir}")
    try:
        risk_svc = RiskService(models_dir)
        forecast_svc = ForecastService(models_dir)
        rec_svc = RecommendationService(models_dir)
        orchestrator_svc = AIOrchestrator(risk_svc, forecast_svc, rec_svc)
        gemini_svc = GeminiSavingsPlanService()

        services["risk"] = risk_svc
        services["forecast"] = forecast_svc
        services["recommendation"] = rec_svc
        services["orchestrator"] = orchestrator_svc
        services["gemini_plan"] = gemini_svc
        logger.info("FinAI AI Services initialized successfully.")
    except Exception as e:
        logger.error(f"Failed to initialize AI services: {e}", exc_info=True)
        raise

    yield

    # Shutdown
    services.clear()
    logger.info("FinAI AI Services shut down.")

app = FastAPI(
    title="FinAI AI Service",
    description="FastAPI Microservice for Financial Risk, Expense Forecasting, Personalized Recommendations, and Gemini Savings Plans",
    version="1.1.0",
    lifespan=lifespan
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health endpoint
@app.get("/health", status_code=status.HTTP_200_OK)
async def health():
    return {
        "status": "ok",
        "service": "finai-ai",
        "version": "1.1.0"
    }

# Risk prediction endpoint
@app.post("/api/v1/ai/risk/predict", response_model=RiskPredictionResponse)
async def predict_risk(request: RiskPredictionRequest):
    try:
        risk_svc: RiskService = services.get("risk")
        if not risk_svc:
            raise HTTPException(status_code=500, detail="Risk service not initialized")
        return risk_svc.predict(request.features)
    except Exception as e:
        logger.error(f"Error in predict_risk: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

# Expense forecast endpoint
@app.post("/api/v1/ai/expense/forecast", response_model=ForecastResponse)
async def forecast_expense(request: ForecastRequest):
    try:
        forecast_svc: ForecastService = services.get("forecast")
        if not forecast_svc:
            raise HTTPException(status_code=500, detail="Forecast service not initialized")
        return forecast_svc.forecast(
            history=request.history or [],
            forecast_months=request.forecastMonths or 6
        )
    except Exception as e:
        logger.error(f"Error in forecast_expense: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

# Recommendation endpoint
@app.post("/api/v1/ai/recommendation/generate", response_model=RecommendationResponse)
async def generate_recommendation(request: RecommendationRequest):
    try:
        rec_svc: RecommendationService = services.get("recommendation")
        if not rec_svc:
            raise HTTPException(status_code=500, detail="Recommendation service not initialized")
        return rec_svc.generate(
            risk_level=request.riskLevel or "Medium Risk",
            health_score=request.financialHealthScore or 60.0,
            top_driver=request.topDriver or "expense_to_income_ratio",
            features=request.features
        )
    except Exception as e:
        logger.error(f"Error in generate_recommendation: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

# Combined Analysis endpoint
@app.post("/api/v1/ai/analyze", response_model=CombinedAnalysisResponse)
async def analyze_full_profile(request: CombinedAnalysisRequest):
    try:
        orch_svc: AIOrchestrator = services.get("orchestrator")
        if not orch_svc:
            raise HTTPException(status_code=500, detail="AI orchestrator not initialized")
        return orch_svc.analyze(request)
    except Exception as e:
        logger.error(f"Error in analyze_full_profile: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

# Gemini Savings Plan Generator endpoint
@app.post("/api/v1/ai/savings-plan/generate", response_model=SavingsPlanResponse)
async def generate_savings_plan(request: SavingsPlanRequest):
    try:
        gemini_svc: GeminiSavingsPlanService = services.get("gemini_plan")
        if not gemini_svc:
            raise HTTPException(status_code=500, detail="Gemini Savings Plan service not initialized")
        return gemini_svc.generate_plan(
            goal_title=request.goalTitle,
            target_amount=request.targetAmount,
            current_amount=request.currentAmount or 0.0,
            target_months=request.targetMonths or 6,
            monthly_income=request.monthlyIncome or 100000.0,
            monthly_expense=request.monthlyExpense or 60000.0,
            current_savings=request.currentSavings or 0.0,
            total_debt=request.totalDebt or 0.0,
            category_expenses=request.categoryExpenses
        )
    except Exception as e:
        logger.error(f"Error in generate_savings_plan: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("AI_SERVICE_PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)
