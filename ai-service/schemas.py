from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field

# ==================== Risk Schemas ====================

class RiskPredictionRequest(BaseModel):
    userId: Optional[int] = 1
    features: Dict[str, Any] = Field(..., description="Map of 42 financial feature names to numeric/string values")

class RiskDriver(BaseModel):
    feature: str
    impact: float
    direction: str  # "increases_risk" or "decreases_risk"
    readableName: str
    description: str

class RiskExplanation(BaseModel):
    topDriver: str
    topDriverReadable: str
    drivers: List[RiskDriver]

class RiskPredictionResponse(BaseModel):
    financialHealthScore: float
    riskLevel: str
    riskProbability: float
    explanation: Optional[RiskExplanation] = None

# ==================== Forecast Schemas ====================

class MonthlyExpenseRecord(BaseModel):
    date: str  # YYYY-MM or YYYY-MM-DD
    food: float = 0.0
    nonFood: float = 0.0
    total: float = 0.0

class ForecastRequest(BaseModel):
    userId: Optional[int] = 1
    history: Optional[List[MonthlyExpenseRecord]] = []
    forecastMonths: Optional[int] = 6

class ForecastPoint(BaseModel):
    date: str  # YYYY-MM-DD
    predictedAmount: float
    lowerBound: Optional[float] = None
    upperBound: Optional[float] = None

class ForecastResponse(BaseModel):
    food: List[ForecastPoint]
    nonFood: List[ForecastPoint]
    total: List[ForecastPoint]
    forecastMonths: int = 6

# ==================== Recommendation Schemas ====================

class RecommendationRequest(BaseModel):
    userId: Optional[int] = 1
    riskLevel: Optional[str] = "Medium Risk"
    financialHealthScore: Optional[float] = 60.0
    topDriver: Optional[str] = "expense_to_income_ratio"
    features: Optional[Dict[str, Any]] = None

class RecommendationResponse(BaseModel):
    category: str
    topDriver: str
    recommendation: str
    actionItems: List[str] = []

# ==================== Combined Analysis Schemas ====================

class CombinedAnalysisRequest(BaseModel):
    userId: Optional[int] = 1
    features: Dict[str, Any] = Field(..., description="Model 1 feature vector")
    expenseHistory: Optional[List[MonthlyExpenseRecord]] = []
    forecastMonths: Optional[int] = 6

class CombinedAnalysisResponse(BaseModel):
    risk: RiskPredictionResponse
    explanation: RiskExplanation
    forecast: ForecastResponse
    recommendation: RecommendationResponse

# ==================== Savings Plan Schemas (Gemini) ====================

class SavingsPlanRequest(BaseModel):
    goalTitle: str
    targetAmount: float
    currentAmount: Optional[float] = 0.0
    targetMonths: Optional[int] = 6
    monthlyIncome: Optional[float] = 100000.0
    monthlyExpense: Optional[float] = 60000.0
    currentSavings: Optional[float] = 0.0
    totalDebt: Optional[float] = 0.0
    categoryExpenses: Optional[Dict[str, float]] = None

class CategoryReduction(BaseModel):
    category: str
    suggestedCut: float
    action: str

class Milestone(BaseModel):
    month: int
    targetAccumulated: float
    completionPercentage: float

class SavingsPlanResponse(BaseModel):
    goalTitle: str
    targetAmount: float
    currentAmount: float
    targetMonths: int
    monthlyRequiredSavings: float
    monthlySurplus: float
    feasibilityScore: float
    feasibilityStatus: str
    difficultyLevel: str
    categoryReductions: List[CategoryReduction] = []
    milestones: List[Milestone] = []
    aiStrategyReport: str
