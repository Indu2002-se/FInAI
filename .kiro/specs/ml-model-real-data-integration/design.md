# Technical Design Document

## Overview

This design specifies the integration of ML model artifacts with real user data throughout the FinAI application. The system currently contains hardcoded financial assumptions, fallback logic with fake data, and duplicated business rules. This implementation will ensure all AI predictions originate from trained ML model artifacts using actual user data from the MySQL database, with explicit error handling when data is insufficient.

### System Context

The FinAI application consists of:
- **Flutter Mobile Frontend**: User-facing mobile application displaying financial predictions
- **Spring Boot Backend**: Java application server responsible for database queries, feature construction, and orchestration
- **FastAPI AI Service**: Python microservice loading ML model artifacts and executing predictions
- **MySQL Database**: Persistent storage for user financial data (UserProfile, Income, Expense, Debt, Savings, Credit)

### ML Models

Three trained ML models provide financial predictions:
- **Model 1 (Risk Assessment)**: XGBoost classifier predicting financial risk level (Low/Medium/High) from 42 features
- **Model 2 (Expense Forecasting)**: Prophet time series models predicting future food, non-food, and total expenses
- **Model 3 (Personalized Recommendations)**: XGBoost classifier assigning financial recommendation categories

### Current State Issues

**Hardcoded Values in FastAPI AI Service**:
- Training baselines (`train_base_food=5300`, `train_base_nf=82000`, `train_base_tot=87300`) in forecast_service.py
- Inflation rate (`inflation_rate=0.005`) during fallback inference in forecast_service.py
- Seasonal multipliers (`seasonal_factor_f`, `seasonal_factor_nf`) during fallback inference in forecast_service.py
- Duplicated threshold values in recommendation_service.py when thresholds exist in model3_recommendation_thresholds.joblib
- Default recommendation messages embedded in source code

**Hardcoded Values in Spring Boot Backend**:
- Demographic defaults (`gender=1`, `age=35`, `education=2`, `maritalStatus=1`) in AiServiceImpl.java
- Income defaults (`totalIncome=50000`, `employmentIncome=totalIncome*0.85`) in AiServiceImpl.java
- Expense defaults (`totalExp=totalIncome*0.50`, `foodExp=totalExp*0.35`) in AiServiceImpl.java
- Credit defaults (`creditScore=650`, `credit_clv=0`, `credit_fraud_txn=0`, etc.) in AiServiceImpl.java

**Fallback Logic Issues**:
- Silent fallback to synthetic predictions when ML models are unavailable
- No explicit error signaling to users when predictions cannot be generated
- Missing `inference_source` field in response DTOs

### Design Goals

1. **Eliminate Hardcoded Assumptions**: Remove all hardcoded demographic, income, expense, and credit defaults from Spring Boot backend
2. **Artifact-Based Configuration**: Load all model parameters, thresholds, and feature lists from .joblib artifact files
3. **Authentic ML Predictions**: Ensure predictions originate from `model.predict()` or `model.predict_proba()` calls
4. **Explicit Error States**: Return clear error responses (INSUFFICIENT_DATA, INVALID_FEATURES, MODEL_UNAVAILABLE) instead of synthetic predictions
5. **Database-Driven Features**: Build feature vectors exclusively from database queries
6. **Preserve Architecture**: Maintain existing Flutter → Spring Boot → FastAPI → ML Model request flow

## Architecture

### High-Level Request Flow

```
Flutter Frontend
    ↓ HTTP POST /api/ai/analysis
Spring Boot Backend
    ↓ Query Database Entities (UserProfile, Income, Expense, Debt, Savings)
    ↓ Construct Feature Vector
    ↓ Validate Feature Completeness
    ↓ (if valid) HTTP POST /api/v1/ai/analyze
FastAPI AI Service
    ↓ Load ML Model Artifacts (.joblib files)
    ↓ Invoke model.predict() / model.predict_proba()
    ↓ Return Predictions with inference_source=ML_MODEL
    ↑ Response with Risk, Forecast, Recommendation
Spring Boot Backend
    ↑ Persist Predictions to Database
    ↑ Return to Frontend
Flutter Frontend
    ↑ Display Results or Error UI
```

### Error Handling Flow

```
Feature Construction Phase (Spring Boot):
  - Missing Database Entity → INSUFFICIENT_DATA
  - Invalid Feature Values → INVALID_FEATURES
  
Model Loading Phase (FastAPI):
  - Missing Artifact File → MODEL_UNAVAILABLE
  
Prediction Phase (FastAPI):
  - Feature Vector Mismatch → INVALID_FEATURES
  - Insufficient History (<3 months) → INSUFFICIENT_HISTORY
```

### Architectural Constraints

- **No Schema Changes**: Existing JSON request/response structures preserved (with addition of `inference_source` field)
- **No Endpoint Changes**: REST API paths and HTTP methods unchanged
- **No New Components**: No additional microservices or architectural layers
- **No Model Replacement**: Trained model artifact files remain unchanged

## Components and Interfaces

### 1. Spring Boot Backend: AiServiceImpl

**Responsibilities**:
- Query database entities for current month data
- Construct 42-feature vector for Model 1 (Risk) and Model 3 (Recommendation)
- Construct expense history for Model 2 (Forecast)
- Validate feature completeness before invoking FastAPI
- Return explicit error responses when data is insufficient

**Modified Methods**:

```java
private Map<String, Object> buildModel1Features(User user)
```
- **Current**: Falls back to hardcoded defaults when database queries return empty results
- **New**: Returns `null` or throws `InsufficientDataException` when required entities are missing
- **Validation**: Checks that all 42 required features can be calculated from database data

```java
private List<Map<String, Object>> buildExpenseHistory(User user)
```
- **Current**: Returns empty list when no expense records exist
- **New**: Returns `null` or throws `InsufficientDataException` when fewer than 3 months of expense data exist
- **Validation**: Ensures minimum 3 months of history for Prophet models

```java
public AiAnalysisResponse runFullAnalysis(User user)
```
- **Current**: Always calls FastAPI even with incomplete data
- **New**: Validates feature vector completeness before calling FastAPI
- **Error Handling**: Returns `AiAnalysisResponse` with `inferenceSource=INSUFFICIENT_DATA` when validation fails

**Removed Hardcoded Values**:
- Demographic: `age=35`, `gender=1`, `education=10`, `maritalStatus=1`
- Income: `totalIncome=50000`, `employmentIncome=totalIncome` (line 235-236)
- Expense: `totalExp=totalIncome*0.50`, `foodExp=totalExp*0.35` (line 274-277)
- Credit: `creditScore=650`, `credit_clv=0`, `credit_fraud_txn=0`, `cc_late_payments=0`, etc. (lines 355-366)

### 2. FastAPI AI Service: RiskService

**Responsibilities**:
- Load Model 1 artifacts at initialization
- Validate feature vector order and completeness
- Invoke XGBoost `model.predict_proba()` for risk prediction
- Return predictions with `inferenceSource=ML_MODEL`

**Modified Methods**:

```python
def load_artifacts(self)
```
- **Current**: Logs error and raises exception if artifacts missing
- **New**: Sets `self.model = None` and logs `MODEL_UNAVAILABLE` if artifacts missing (graceful degradation)

```python
def predict(self, raw_features: Dict[str, Any]) -> RiskPredictionResponse
```
- **Current**: Builds feature vector and calls `model.predict_proba()`
- **New**: 
  - Validates feature vector length matches `len(self.feature_cols)`
  - Validates feature names match `model.feature_names_in_`
  - Returns error response if validation fails
  - Sets `inferenceSource="ML_MODEL"` on success

**Artifact Files**:
- `model1_financial_risk_xgb.joblib`: Trained XGBoost classifier
- `model1_feature_cols.joblib`: Ordered list of 42 feature names
- `model1_label_map.joblib`: Risk level label mapping {0: "High Risk", 1: "Medium Risk", 2: "Low Risk"}

### 3. FastAPI AI Service: ForecastService

**Responsibilities**:
- Load Model 2 Prophet artifacts at initialization
- Validate expense history sufficiency (minimum 3 months)
- Invoke Prophet `model.predict()` for food, non-food, and total expense forecasts
- Return predictions with `inferenceSource=ML_MODEL`

**Modified Methods**:

```python
def load_artifacts(self)
```
- **Current**: Loads Prophet models from .joblib files
- **New**: Sets models to `None` if artifacts missing; logs `MODEL_UNAVAILABLE`

```python
def forecast(self, history: List[MonthlyExpenseRecord], forecast_months: int = 6) -> ForecastResponse
```
- **Current**: Falls back to seasonal trend model when Prophet fails
- **New**:
  - Validates `len(history) >= 3` before processing
  - Returns `ForecastResponse` with `inferenceSource=INSUFFICIENT_HISTORY` if validation fails
  - Removes hardcoded training baselines (`train_base_food`, `train_base_nf`, `train_base_tot`) from inference logic
  - Removes hardcoded inflation rate and seasonal multipliers from fallback
  - Sets `inferenceSource="ML_MODEL"` when Prophet models succeed

**Removed Hardcoded Values**:
- Training baselines: `train_base_food=5300`, `train_base_nf=82000`, `train_base_tot=87300` (lines 68-70)
- Fallback inflation rate: `inflation_rate=0.005` (line 124)
- Fallback seasonal multipliers: `seasonal_factor_f`, `seasonal_factor_nf` (lines 128-129)

**Artifact Files**:
- `model2_food_prophet.joblib`: Trained Prophet model for food expenses
- `model2_nonfood_prophet.joblib`: Trained Prophet model for non-food expenses
- `model2_total_prophet.joblib`: Trained Prophet model for total expenses
- `model2_forecast_config.joblib`: Forecast configuration parameters

### 4. FastAPI AI Service: RecommendationService

**Responsibilities**:
- Load Model 3 artifacts at initialization
- Invoke XGBoost `model.predict()` for recommendation category
- Return predictions with `inferenceSource=ML_MODEL`
- Load thresholds from artifacts (remove duplicated hardcoded thresholds)

**Modified Methods**:

```python
def load_artifacts(self)
```
- **Current**: Loads XGBoost model, label map, thresholds, and recommendation text
- **New**: Sets `self.model = None` if artifacts missing; logs `MODEL_UNAVAILABLE`

```python
def generate(self, risk_level, health_score, top_driver, features) -> RecommendationResponse
```
- **Current**: Attempts ML prediction, falls back to rule-based thresholds
- **New**:
  - Prioritizes `model.predict()` when model is available
  - Sets `inferenceSource="ML_MODEL"` when XGBoost succeeds
  - Sets `inferenceSource="RULE_FALLBACK"` only when model is unavailable
  - Uses thresholds from `model3_recommendation_thresholds.joblib` exclusively (no hardcoded duplicates)

```python
def _generate_rule_fallback(self, risk_level, health_score, top_driver, features) -> str
```
- **Current**: Contains hardcoded threshold values (`debt_to_income_high=0.1314`, etc.) in source code
- **New**: References `self.thresholds` loaded from artifact file only

**Removed Hardcoded Values**:
- Threshold duplicates in source code (lines 150-154 in original implementation)

**Artifact Files**:
- `model3_recommendation_xgb.joblib`: Trained XGBoost classifier
- `model3_recommendation_label_map.joblib`: Recommendation category mapping
- `model3_recommendation_thresholds.joblib`: Fallback threshold values
- `model3_recommendation_text.joblib`: Recommendation text templates

### 5. Response DTOs (Spring Boot)

**Modified DTOs**:

```java
public class FinancialRiskResponse {
    private BigDecimal financialHealthScore;
    private String riskLevel;
    private BigDecimal riskProbability;
    private String topDriver;
    private String topDriverReadable;
    private List<DriverDetail> drivers;
    private String inferenceSource; // NEW FIELD
}

public class ExpenseForecastResponse {
    private List<ForecastItem> food;
    private List<ForecastItem> nonFood;
    private List<ForecastItem> total;
    private int forecastMonths;
    private String inferenceSource; // NEW FIELD
}

public class AiRecommendationResponse {
    private String category;
    private String topDriver;
    private String recommendationText;
    private List<String> actionItems;
    private boolean isApplied;
    private String inferenceSource; // NEW FIELD
}
```

**Inference Source Values**:
- `ML_MODEL`: Prediction generated by trained ML model
- `INSUFFICIENT_DATA`: Required database entities missing
- `INVALID_FEATURES`: Feature vector validation failed
- `MODEL_UNAVAILABLE`: ML model artifact failed to load
- `INSUFFICIENT_HISTORY`: Expense history contains fewer than 3 months
- `RULE_FALLBACK`: Fallback rule-based calculation (only when model unavailable at initialization)

### 6. Flutter Frontend: Error Handling

**Responsibilities**:
- Display appropriate error messages when `inferenceSource != "ML_MODEL"`
- Prompt users to complete financial profile when `inferenceSource == "INSUFFICIENT_DATA"`
- Show "Service temporarily unavailable" when `inferenceSource == "MODEL_UNAVAILABLE"`

**Modified Components**:

```dart
Widget buildRiskCard(FinancialRiskResponse risk)
```
- **New**: Checks `risk.inferenceSource`
- Displays error UI if not `ML_MODEL`

```dart
Widget buildForecastChart(ExpenseForecastResponse forecast)
```
- **New**: Checks `forecast.inferenceSource`
- Displays error message if not `ML_MODEL`

```dart
Widget buildRecommendationCard(AiRecommendationResponse recommendation)
```
- **New**: Checks `recommendation.inferenceSource`
- Displays appropriate error message or prompt

## Data Models

### Feature Vector Structure (Model 1 & 3)

**42 Features (Ordered)**:
```
1.  age: double
2.  gender: double (1=Male, 2=Female)
3.  education: double (5-19 scale)
4.  marital_status: double (1=Single, 2=Married, 3=Widowed, 4=Divorced)
5.  household_size_f: double
6.  employment_income: double
7.  other_income: double
8.  windfall_income: double
9.  agri_income: double
10. non_agri_income: double
11. transfer_income: double
12. total_income: double
13. food_expenditure: double
14. nonfood_expenditure: double
15. total_expenditure: double
16. expense_to_income_ratio: double
17. financial_surplus: double
18. savings_ratio: double
19. per_capita_income: double
20. employment_capacity: double
21. debt_amount: double
22. debt_records: double
23. debt_sources: double
24. debt_to_income_ratio: double
25. credit_card_debt: double
26. has_credit_card_debt: double (1=Yes, 2=No)
27. has_creditmix_match: double
28. credit_score: double
29. credit_defaulted: double
30. credit_clv: double
31. credit_fraud_txn: double
32. cc_utilization_ratio: double
33. cc_late_payments: double
34. cc_credit_lines: double
35. cc_debt_to_income_ratio: double
36. cc_total_spend_last_year: double
37. cc_avg_txn_amount: double
38. cc_total_txns: double
39. cc_tenure_years: double
40. vehicle_ownership: double
41. instalment_goods_flag: double (1=Yes, 2=No)
42. instalment_amount: double
```

**Feature Order Requirement**: Feature vector MUST be ordered exactly as specified above to match model training.

**Validation Rules**:
- All features must be present (no null values)
- Feature count must equal 42
- Feature names must match `model.feature_names_in_` attribute

### Expense History Structure (Model 2)

**MonthlyExpenseRecord**:
```json
{
  "date": "YYYY-MM-DD",
  "food": 25000.0,
  "nonFood": 20000.0,
  "total": 45000.0
}
```

**Validation Rules**:
- Minimum 3 months of history required for Prophet models
- Dates must be chronologically sorted
- All monetary values must be non-negative

### Database Entity Mapping

**UserProfile → Features**:
- `age` → feature 1
- `gender` → feature 2 (encoded)
- `education` → feature 3 (encoded)
- `maritalStatus` → feature 4 (encoded)
- `householdSize` → feature 5
- `dependentsCount` → used to calculate `employment_capacity` (feature 20)
- `creditScore` → feature 28
- `monthlyIncome` → fallback for feature 12 if no Income entities exist
- `monthlyExpense` → fallback for feature 15 if no Expense entities exist
- `totalDebt` → fallback for feature 21 if no Debt entities exist

**Income Entities → Features**:
- Query: `findByUserAndIncomeDateBetween(user, startOfMonth, endOfMonth)`
- `SALARY`, `BUSINESS`, `FREELANCE` → `employment_income` (feature 6)
- `WINDFALL` → `windfall_income` (feature 8)
- `AGRICULTURE` → `agri_income` (feature 9)
- `INVESTMENT`, `OTHER` → `other_income` (feature 7)
- Sum all → `total_income` (feature 12)

**Expense Entities → Features**:
- Query: `findByUserAndExpenseDateBetween(user, startOfMonth, endOfMonth)`
- Category `FOOD` → `food_expenditure` (feature 13)
- All other categories → `nonfood_expenditure` (feature 14)
- Sum all → `total_expenditure` (feature 15)

**Debt Entities → Features**:
- Query: `findByUser(user)` filtered by `status=ACTIVE`
- Sum `remainingAmount` → `debt_amount` (feature 21)
- Count active debts → `debt_records` (feature 22)
- Count distinct sources → `debt_sources` (feature 23)
- Filter `isCreditCard=true` → `credit_card_debt` (feature 25), `cc_credit_lines` (feature 34)
- Check `status=DEFAULTED` → `credit_defaulted` (feature 29)

**Savings Entities → Features**:
- Query: `sumTotalSavingsByUser(user)`
- Sum all savings → used to calculate `savings_ratio` (feature 18)

**Derived Features**:
- `expense_to_income_ratio` (16) = `total_expenditure` / `total_income`
- `financial_surplus` (17) = `total_income` - `total_expenditure`
- `savings_ratio` (18) = `financial_surplus` / `total_income`
- `per_capita_income` (19) = `total_income` / `household_size_f`
- `employment_capacity` (20) = max(1, `household_size_f` - `dependentsCount`) / `household_size_f`
- `debt_to_income_ratio` (24) = `debt_amount` / `total_income`
- `cc_utilization_ratio` (32) = `credit_card_debt` / `total_income`
- `cc_debt_to_income_ratio` (35) = `credit_card_debt` / `total_income`

### Artifact File Specifications

**Model 1 Risk Assessment**:
- `model1_financial_risk_xgb.joblib`: XGBoost Booster object
- `model1_feature_cols.joblib`: List[str] of 42 feature names in order
- `model1_label_map.joblib`: Dict[int, str] mapping class indices to risk levels

**Model 2 Expense Forecasting**:
- `model2_food_prophet.joblib`: Prophet model instance
- `model2_nonfood_prophet.joblib`: Prophet model instance
- `model2_total_prophet.joblib`: Prophet model instance
- `model2_forecast_config.joblib`: Dict with `future_periods`, `frequency` keys

**Model 3 Recommendations**:
- `model3_recommendation_xgb.joblib`: XGBoost Booster object
- `model3_recommendation_label_map.joblib`: Dict[int, str] mapping class indices to categories
- `model3_recommendation_thresholds.joblib`: Dict with threshold values (`debt_to_income_high`, `savings_ratio_low`, etc.)
- `model3_recommendation_text.joblib`: Dict with `driver_text` and `action_text` mappings

## Error Handling

### Error Types and Responses

**1. INSUFFICIENT_DATA**
- **Trigger**: Required database entities missing (no UserProfile, no Income records, no Expense records for current month)
- **Spring Boot Response**:
```json
{
  "risk": {
    "inferenceSource": "INSUFFICIENT_DATA",
    "financialHealthScore": null,
    "riskLevel": null,
    "riskProbability": null,
    "topDriver": null,
    "drivers": []
  },
  "forecast": {...},
  "recommendation": {...}
}
```
- **Frontend Action**: Display prompt "Please complete your financial profile to receive personalized predictions"

**2. INVALID_FEATURES**
- **Trigger**: Feature vector validation fails (length mismatch, name mismatch, invalid values)
- **FastAPI Response**:
```json
{
  "detail": "Feature validation failed: Expected 42 features, got 40",
  "inferenceSource": "INVALID_FEATURES"
}
```
- **Spring Boot Handling**: Catches exception, returns error response to frontend
- **Frontend Action**: Display "Unable to process financial data. Please contact support."

**3. MODEL_UNAVAILABLE**
- **Trigger**: ML model artifact files missing or failed to load at FastAPI initialization
- **FastAPI Response**:
```json
{
  "risk": {
    "inferenceSource": "MODEL_UNAVAILABLE",
    "financialHealthScore": null,
    "riskLevel": null
  }
}
```
- **Frontend Action**: Display "Prediction service temporarily unavailable. Please try again later."

**4. INSUFFICIENT_HISTORY**
- **Trigger**: Expense history contains fewer than 3 months of data
- **FastAPI Response**:
```json
{
  "forecast": {
    "inferenceSource": "INSUFFICIENT_HISTORY",
    "food": [],
    "nonFood": [],
    "total": [],
    "forecastMonths": 0
  }
}
```
- **Frontend Action**: Display "Insufficient expense history. Add at least 3 months of expenses to receive forecasts."

**5. RULE_FALLBACK**
- **Trigger**: ML model unavailable, fallback rule-based logic executed
- **FastAPI Response**:
```json
{
  "recommendation": {
    "inferenceSource": "RULE_FALLBACK",
    "category": "Expense Optimization",
    "topDriver": "expense_to_income_ratio",
    "recommendationText": "...",
    "actionItems": [...]
  }
}
```
- **Frontend Action**: Display recommendation with disclaimer "Based on general financial guidelines"

### Error Propagation

```
Database Query Failure → INSUFFICIENT_DATA → Spring Boot returns error response
Feature Validation Failure → INVALID_FEATURES → Spring Boot catches and returns error
Model Loading Failure → MODEL_UNAVAILABLE → FastAPI returns error response
History Validation Failure → INSUFFICIENT_HISTORY → FastAPI returns error response
FastAPI Unavailable → Spring Boot returns MODEL_UNAVAILABLE
```

### Logging Requirements

**Spring Boot Logs**:
- Log feature construction start and completion
- Log validation failures with details
- Log FastAPI request failures
- Log `inferenceSource` value for all responses

**FastAPI Logs**:
- Log artifact loading success/failure at initialization
- Log model prediction success/failure
- Log feature validation errors with mismatch details
- Log `inferenceSource` value for all responses

### Graceful Degradation Rules

1. **Feature Construction Phase**: If any required database entity is missing, return `INSUFFICIENT_DATA` immediately (do not call FastAPI)
2. **Model Loading Phase**: If artifact files are missing, set `model = None` and log `MODEL_UNAVAILABLE` (service remains operational)
3. **Prediction Phase**: If model is `None`, return error response with `MODEL_UNAVAILABLE` (do not generate synthetic predictions)
4. **Fallback Logic**: Rule-based fallback only executes when ML model is unavailable at initialization (not during normal operation)

## Correctness Properties

This feature does not include correctness properties for property-based testing. Property-based testing (PBT) is **not applicable** to this feature because:

1. **ML Model Integration**: Testing ML model behavior requires example-based validation with known inputs/outputs, not property testing
2. **Database Integration**: Testing database query logic requires integration tests with real or mocked database connections  
3. **Error Handling**: Testing error states requires specific edge cases (missing data, invalid features), not universal properties
4. **External Service Calls**: Testing FastAPI integration requires mock-based tests or integration tests

There are no universal properties that can be meaningfully validated through property-based testing. Instead, comprehensive testing will be achieved through example-based unit tests, integration tests, and end-to-end tests as detailed in the Testing Strategy section below.

## Testing Strategy

This feature involves business logic with data transformations, ML model integrations, and error handling. Property-based testing (PBT) is **NOT appropriate** for this feature because:

1. **ML Model Integration**: Testing ML model behavior requires example-based validation with known inputs/outputs, not property testing
2. **Database Integration**: Testing database query logic requires integration tests with real or mocked database connections
3. **Error Handling**: Testing error states requires specific edge cases (missing data, invalid features), not universal properties
4. **External Service Calls**: Testing FastAPI integration requires mock-based tests or integration tests

**Testing Approach**: Example-based unit tests, integration tests, and end-to-end tests.

### Unit Testing Strategy

**Spring Boot Backend (AiServiceImpl)**:

**Feature Construction Tests**:
- **Test**: `testBuildModel1Features_WithCompleteData_ReturnsCorrectFeatureVector`
  - Setup: Mock complete UserProfile, Income, Expense, Debt, Savings entities
  - Action: Call `buildModel1Features(user)`
  - Assert: Feature vector contains exactly 42 features with correct values
  - Assert: Feature order matches `model1_feature_cols.joblib` specification

- **Test**: `testBuildModel1Features_WithMissingUserProfile_ReturnsNull`
  - Setup: User with no UserProfile entity
  - Action: Call `buildModel1Features(user)`
  - Assert: Returns `null` or throws `InsufficientDataException`

- **Test**: `testBuildModel1Features_WithNoIncomeRecords_UsesProfileFallback`
  - Setup: UserProfile with `monthlyIncome=50000`, no Income entities
  - Action: Call `buildModel1Features(user)`
  - Assert: `total_income` feature equals 50000
  - Assert: `employment_income` feature equals 50000

- **Test**: `testBuildModel1Features_WithNoIncomeAndNoProfile_ReturnsNull`
  - Setup: No Income entities, no UserProfile, or UserProfile with null monthlyIncome
  - Action: Call `buildModel1Features(user)`
  - Assert: Returns `null` or throws `InsufficientDataException`

- **Test**: `testBuildExpenseHistory_WithSufficientHistory_ReturnsCorrectList`
  - Setup: Mock 6 months of Expense entities
  - Action: Call `buildExpenseHistory(user)`
  - Assert: Returns list of 6 MonthlyExpenseRecords
  - Assert: Records are chronologically sorted
  - Assert: `total = food + nonFood` for each record

- **Test**: `testBuildExpenseHistory_WithInsufficientHistory_ReturnsNull`
  - Setup: Mock only 2 months of Expense entities
  - Action: Call `buildExpenseHistory(user)`
  - Assert: Returns `null` or throws `InsufficientDataException`

**Analysis Orchestration Tests**:
- **Test**: `testRunFullAnalysis_WithCompleteData_CallsFastAPIAndReturnsMLModel`
  - Setup: Mock complete database entities, mock successful FastAPI response
  - Action: Call `runFullAnalysis(user)`
  - Assert: FastAPI endpoint called with correct payload
  - Assert: Response contains `inferenceSource=ML_MODEL` for all components

- **Test**: `testRunFullAnalysis_WithInsufficientData_ReturnsINSUFFICIENT_DATA`
  - Setup: User with incomplete database entities
  - Action: Call `runFullAnalysis(user)`
  - Assert: FastAPI endpoint NOT called
  - Assert: Response contains `inferenceSource=INSUFFICIENT_DATA`

- **Test**: `testRunFullAnalysis_WithFastAPIFailure_ReturnsMODEL_UNAVAILABLE`
  - Setup: Mock complete database entities, mock FastAPI connection failure
  - Action: Call `runFullAnalysis(user)`
  - Assert: Response contains `inferenceSource=MODEL_UNAVAILABLE`

**Encoding Tests**:
- **Test**: `testEncodeGender_WithMale_Returns1`
- **Test**: `testEncodeGender_WithFemale_Returns2`
- **Test**: `testEncodeEducation_WithDoctorate_Returns19`
- **Test**: `testEncodeEducation_WithBachelor_Returns13`
- **Test**: `testEncodeMaritalStatus_WithMarried_Returns2`

**FastAPI AI Service (Python)**:

**RiskService Tests**:
- **Test**: `test_load_artifacts_success`
  - Setup: All artifact files present
  - Action: Call `load_artifacts()`
  - Assert: `self.model` is not None
  - Assert: `len(self.feature_cols) == 42`
  - Assert: `self.label_map` contains expected keys

- **Test**: `test_load_artifacts_missing_model_file`
  - Setup: Model file missing
  - Action: Call `load_artifacts()`
  - Assert: `self.model is None`
  - Assert: Log contains `MODEL_UNAVAILABLE`

- **Test**: `test_predict_with_valid_features`
  - Setup: Mock trained model, valid 42-feature input
  - Action: Call `predict(raw_features)`
  - Assert: Response contains valid risk level
  - Assert: `inferenceSource == "ML_MODEL"`
  - Assert: `model.predict_proba()` called once

- **Test**: `test_predict_with_invalid_feature_count`
  - Setup: Input contains only 40 features
  - Action: Call `predict(raw_features)`
  - Assert: Response contains error
  - Assert: `inferenceSource == "INVALID_FEATURES"`

- **Test**: `test_predict_with_model_unavailable`
  - Setup: `self.model = None`
  - Action: Call `predict(raw_features)`
  - Assert: Response contains error
  - Assert: `inferenceSource == "MODEL_UNAVAILABLE"`

**ForecastService Tests**:
- **Test**: `test_load_artifacts_success`
  - Setup: All Prophet model files present
  - Action: Call `load_artifacts()`
  - Assert: All three models loaded successfully

- **Test**: `test_forecast_with_sufficient_history`
  - Setup: Mock 6 months of expense history
  - Action: Call `forecast(history, forecast_months=6)`
  - Assert: Response contains 6 forecast points
  - Assert: `inferenceSource == "ML_MODEL"`
  - Assert: Prophet `model.predict()` called for each category

- **Test**: `test_forecast_with_insufficient_history`
  - Setup: Only 2 months of expense history
  - Action: Call `forecast(history, forecast_months=6)`
  - Assert: Response contains error
  - Assert: `inferenceSource == "INSUFFICIENT_HISTORY"`

- **Test**: `test_forecast_with_model_unavailable`
  - Setup: All Prophet models are None
  - Action: Call `forecast(history, forecast_months=6)`
  - Assert: Response contains error
  - Assert: `inferenceSource == "MODEL_UNAVAILABLE"`

**RecommendationService Tests**:
- **Test**: `test_load_artifacts_success`
  - Setup: All artifact files present
  - Action: Call `load_artifacts()`
  - Assert: Model, label map, thresholds, text loaded

- **Test**: `test_generate_with_ml_model`
  - Setup: Mock trained model, valid features
  - Action: Call `generate(risk_level, health_score, top_driver, features)`
  - Assert: Category from model prediction
  - Assert: `inferenceSource == "ML_MODEL"`
  - Assert: `model.predict()` called once

- **Test**: `test_generate_with_rule_fallback`
  - Setup: `self.model = None`, valid features
  - Action: Call `generate(risk_level, health_score, top_driver, features)`
  - Assert: Category from rule-based logic
  - Assert: `inferenceSource == "RULE_FALLBACK"`
  - Assert: Thresholds loaded from `self.thresholds` (not hardcoded)

### Integration Testing Strategy

**Database Integration Tests**:
- **Test**: `testFeatureConstruction_IntegrationWithRealDatabase`
  - Setup: Populate test database with complete user financial data
  - Action: Call `buildModel1Features(user)`
  - Assert: Feature vector constructed correctly from database queries
  - Assert: No hardcoded defaults used

- **Test**: `testExpenseHistoryConstruction_IntegrationWithRealDatabase`
  - Setup: Populate test database with 6 months of expense records
  - Action: Call `buildExpenseHistory(user)`
  - Assert: Expense history matches database records

**FastAPI Integration Tests**:
- **Test**: `testFullAnalysis_IntegrationWithFastAPI`
  - Setup: Start FastAPI service, populate test database
  - Action: Call Spring Boot `runFullAnalysis(user)`
  - Assert: Request sent to FastAPI `/api/v1/ai/analyze`
  - Assert: Response contains predictions with `inferenceSource=ML_MODEL`

- **Test**: `testRiskPrediction_IntegrationWithFastAPI`
  - Setup: Start FastAPI service
  - Action: POST to `/api/v1/ai/risk/predict` with valid features
  - Assert: Response contains risk level
  - Assert: `inferenceSource=ML_MODEL`

- **Test**: `testForecastPrediction_IntegrationWithFastAPI`
  - Setup: Start FastAPI service
  - Action: POST to `/api/v1/ai/expense/forecast` with valid history
  - Assert: Response contains forecast points
  - Assert: `inferenceSource=ML_MODEL`

### End-to-End Testing Strategy

**Full Workflow Tests**:
- **Test**: `testFullWorkflow_FlutterToFastAPI_WithCompleteData`
  - Setup: Populate database, start all services
  - Action: Flutter sends POST to `/api/ai/analysis`
  - Assert: Spring Boot queries database
  - Assert: Spring Boot calls FastAPI
  - Assert: FastAPI returns predictions
  - Assert: Spring Boot persists results
  - Assert: Flutter receives response with `inferenceSource=ML_MODEL`

- **Test**: `testFullWorkflow_WithInsufficientData`
  - Setup: User with incomplete profile
  - Action: Flutter sends POST to `/api/ai/analysis`
  - Assert: Spring Boot returns error response
  - Assert: FastAPI NOT called
  - Assert: Flutter displays "Complete your profile" prompt

- **Test**: `testFullWorkflow_WithModelUnavailable`
  - Setup: Remove artifact files, start services
  - Action: Flutter sends POST to `/api/ai/analysis`
  - Assert: FastAPI returns `MODEL_UNAVAILABLE`
  - Assert: Flutter displays "Service temporarily unavailable"

### Test Data Requirements

**Minimum Test Data**:
- User with complete UserProfile (age, gender, education, maritalStatus, householdSize, creditScore)
- 1 month of Income records (multiple categories)
- 1 month of Expense records (FOOD and non-FOOD categories)
- 1 active Debt record
- 1 Savings record
- 6 months of Expense history for forecasting tests

**Edge Case Test Data**:
- User with no UserProfile
- User with no Income records
- User with no Expense records
- User with only 2 months of Expense history
- User with no Debt records
- User with defaulted Debt status

### Test Coverage Goals

- **Unit Test Coverage**: ≥80% for AiServiceImpl, RiskService, ForecastService, RecommendationService
- **Integration Test Coverage**: All database query paths, all FastAPI endpoints
- **End-to-End Test Coverage**: All error states (INSUFFICIENT_DATA, INVALID_FEATURES, MODEL_UNAVAILABLE, INSUFFICIENT_HISTORY)

### Validation Tests

**Feature Vector Validation Tests**:
- Validate that different users produce different feature vectors
- Validate that feature vector order matches `model1_feature_cols.joblib`
- Validate that no hardcoded defaults are used when database data exists
- Validate that `null` or exception is returned when required data is missing

**ML Model Validation Tests**:
- Validate that different feature vectors produce different ML predictions
- Validate that `model.predict()` or `model.predict_proba()` is called
- Validate that `inferenceSource=ML_MODEL` when model prediction succeeds
- Validate that fallback logic is NOT executed when model is available

**Error State Validation Tests**:
- Validate that `INSUFFICIENT_DATA` is returned when database entities are missing
- Validate that `MODEL_UNAVAILABLE` is returned when artifacts fail to load
- Validate that `INSUFFICIENT_HISTORY` is returned when expense history is too short
- Validate that Frontend displays appropriate error messages for each error state

### Test Execution

**Unit Tests**: Run with `mvn test` (Spring Boot) and `pytest` (FastAPI)
**Integration Tests**: Run with `mvn verify` (Spring Boot with embedded database) and `pytest --integration` (FastAPI with Docker)
**End-to-End Tests**: Run with dedicated test environment (all services running)

### Continuous Integration

- All tests run on every commit
- Integration tests run on every pull request
- End-to-end tests run nightly or before release
- Test failures block deployment

