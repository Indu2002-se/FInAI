# Requirements Document

## Introduction

This specification defines the requirements for integrating ML model artifacts with real user data throughout the FinAI application. The system currently contains hardcoded financial assumptions, fallback logic with fake data, and duplicated business rules. This feature will ensure all AI predictions come from trained ML model artifacts using actual user data from the database, with explicit error handling when data is insufficient.

The FinAI application consists of a Flutter mobile frontend, Spring Boot backend, FastAPI AI service, and MySQL database. Three trained ML models provide financial predictions: XGBoost Risk Assessment (Model 1), Prophet Expense Forecasting (Model 2), and XGBoost Personalized Recommendations (Model 3).

## Glossary

- **ML_Model**: Machine learning model artifact (XGBoost or Prophet) trained on historical data and loaded from .joblib files
- **Feature_Vector**: Ordered set of numerical values representing user financial data, used as input to ML_Model
- **Spring_Boot_Backend**: Java-based application server responsible for database queries and feature construction
- **FastAPI_AI_Service**: Python microservice that loads ML_Model artifacts and executes predictions
- **Flutter_Frontend**: Mobile application that displays predictions to users
- **Inference_Source**: Enumeration indicating origin of prediction (ML_MODEL, FALLBACK, INSUFFICIENT_DATA, MODEL_UNAVAILABLE, INVALID_FEATURES)
- **Hardcoded_Value**: Static numerical constant embedded in source code rather than derived from data or model
- **Artifact**: Serialized ML model file (.joblib) containing trained parameters, feature lists, thresholds, or label mappings
- **Database_Entity**: Persistent data structure (UserProfile, Income, Expense, Debt, Savings, Credit) stored in MySQL
- **Target_Leakage**: Inclusion of outcome variable (e.g., credit_defaulted) as input feature to prediction model
- **Model1_Risk**: XGBoost classifier predicting financial risk level (Low/Medium/High) from 42 features
- **Model2_Forecast**: Prophet time series models predicting future food, non-food, and total expenses
- **Model3_Recommendation**: XGBoost classifier assigning financial recommendation categories

## Requirements

### Requirement 1: Eliminate Hardcoded Financial Assumptions

**User Story:** As a developer, I want all financial assumptions removed from the codebase, so that predictions reflect actual user data rather than invented values.

#### Acceptance Criteria

1. THE Spring_Boot_Backend SHALL NOT contain hardcoded demographic values (gender=1, age=35, education=2, marital_status=1)
2. THE Spring_Boot_Backend SHALL NOT contain hardcoded income defaults (totalIncome=50000, employmentIncome=totalIncome*0.85)
3. THE Spring_Boot_Backend SHALL NOT contain hardcoded expense defaults (totalExp=totalIncome*0.50, foodExp=totalExp*0.35)
4. THE Spring_Boot_Backend SHALL NOT contain hardcoded credit defaults (creditScore=650, credit_clv=0, credit_fraud_txn=0, cc_late_payments=0, cc_total_spend_last_year=0, cc_avg_txn_amount=0, cc_total_txns=0, cc_tenure_years=0, vehicle_ownership=0)
5. THE FastAPI_AI_Service SHALL NOT contain hardcoded training baselines (train_base_food=5300, train_base_nf=82000, train_base_tot=87300)
6. THE FastAPI_AI_Service SHALL NOT contain hardcoded inflation rates (inflation_rate=0.005) during normal inference
7. THE FastAPI_AI_Service SHALL NOT contain hardcoded seasonal multipliers (seasonal_factor_f, seasonal_factor_nf) during normal inference
8. THE FastAPI_AI_Service SHALL NOT contain duplicated threshold values in source code when thresholds exist in Artifact files
9. WHERE thresholds are required for business logic, THE System SHALL load them from model3_recommendation_thresholds.joblib

### Requirement 2: Database-Driven Feature Construction

**User Story:** As a system architect, I want feature vectors built exclusively from database queries, so that predictions use real user financial history.

#### Acceptance Criteria

1. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL query UserProfile entity for demographic data
2. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL query Income entities for current month income breakdown
3. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL query Expense entities for current month expenditure breakdown
4. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL query Debt entities for active debt obligations and credit card data
5. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL query Savings entities for total savings balance
6. WHEN building Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL calculate derived features (expense_to_income_ratio, debt_to_income_ratio, financial_surplus, savings_ratio, per_capita_income, employment_capacity) mathematically from queried data
7. THE Spring_Boot_Backend SHALL validate that all required features from model1_feature_cols.joblib are available before invoking FastAPI_AI_Service
8. IF any required feature cannot be calculated from Database_Entity data, THEN THE Spring_Boot_Backend SHALL return INSUFFICIENT_DATA status without invoking FastAPI_AI_Service

### Requirement 3: Artifact-Based Model Loading

**User Story:** As a data scientist, I want all model parameters loaded from artifacts, so that code changes are not required when models are retrained.

#### Acceptance Criteria

1. WHEN Model1_Risk service initializes, THE FastAPI_AI_Service SHALL load XGBoost model from model1_financial_risk_xgb.joblib
2. WHEN Model1_Risk service initializes, THE FastAPI_AI_Service SHALL load feature column list from model1_feature_cols.joblib
3. WHEN Model1_Risk service initializes, THE FastAPI_AI_Service SHALL load label mapping from model1_label_map.joblib
4. WHEN Model2_Forecast service initializes, THE FastAPI_AI_Service SHALL load Prophet models from model2_food_prophet.joblib, model2_nonfood_prophet.joblib, and model2_total_prophet.joblib
5. WHEN Model2_Forecast service initializes, THE FastAPI_AI_Service SHALL load forecast configuration from model2_forecast_config.joblib
6. WHEN Model3_Recommendation service initializes, THE FastAPI_AI_Service SHALL load XGBoost model from model3_recommendation_xgb.joblib
7. WHEN Model3_Recommendation service initializes, THE FastAPI_AI_Service SHALL load label mapping from model3_recommendation_label_map.joblib
8. WHEN Model3_Recommendation service initializes, THE FastAPI_AI_Service SHALL load threshold values from model3_recommendation_thresholds.joblib
9. WHEN Model3_Recommendation service initializes, THE FastAPI_AI_Service SHALL load recommendation text from model3_recommendation_text.joblib
10. IF any required Artifact file is missing, THEN THE FastAPI_AI_Service SHALL log an error and set model status to MODEL_UNAVAILABLE

### Requirement 4: Authentic ML Model Prediction

**User Story:** As a product manager, I want predictions generated by model.predict() calls, so that users receive genuine ML predictions rather than rule-based approximations.

#### Acceptance Criteria

1. WHEN Feature_Vector is provided to Model1_Risk service, THE FastAPI_AI_Service SHALL invoke model.predict_proba() to generate risk probabilities
2. WHEN Feature_Vector is provided to Model1_Risk service, THE FastAPI_AI_Service SHALL select risk level from prediction output using label mapping
3. WHEN expense history and forecast period are provided to Model2_Forecast service, THE FastAPI_AI_Service SHALL invoke Prophet model.predict() for food expenses
4. WHEN expense history and forecast period are provided to Model2_Forecast service, THE FastAPI_AI_Service SHALL invoke Prophet model.predict() for non-food expenses
5. WHEN expense history and forecast period are provided to Model2_Forecast service, THE FastAPI_AI_Service SHALL invoke Prophet model.predict() for total expenses
6. WHEN Feature_Vector is provided to Model3_Recommendation service, THE FastAPI_AI_Service SHALL invoke XGBoost model.predict() to determine recommendation category
7. THE FastAPI_AI_Service SHALL return Inference_Source=ML_MODEL when predictions are generated by model.predict() or model.predict_proba()
8. THE FastAPI_AI_Service SHALL NOT substitute rule-based calculations for ML_Model output during normal operation

### Requirement 5: Explicit Error State Handling

**User Story:** As a mobile user, I want clear feedback when predictions cannot be generated, so that I understand why recommendations are unavailable.

#### Acceptance Criteria

1. IF required Database_Entity data is missing, THEN THE Spring_Boot_Backend SHALL return response with Inference_Source=INSUFFICIENT_DATA
2. IF Feature_Vector validation fails, THEN THE Spring_Boot_Backend SHALL return response with Inference_Source=INVALID_FEATURES
3. IF ML_Model artifact fails to load, THEN THE FastAPI_AI_Service SHALL return response with Inference_Source=MODEL_UNAVAILABLE
4. IF expense history contains fewer than 3 months of data, THEN THE Model2_Forecast service SHALL return Inference_Source=INSUFFICIENT_HISTORY
5. THE FastAPI_AI_Service SHALL NOT silently generate fake predictions when ML_Model is unavailable
6. THE Spring_Boot_Backend SHALL include Inference_Source field in all prediction response DTOs
7. THE Flutter_Frontend SHALL display appropriate error messages when Inference_Source is not ML_MODEL
8. WHERE Inference_Source=INSUFFICIENT_DATA, THE Flutter_Frontend SHALL prompt user to complete financial profile
9. WHERE Inference_Source=MODEL_UNAVAILABLE, THE Flutter_Frontend SHALL display "Service temporarily unavailable" message

### Requirement 6: Feature Order Consistency

**User Story:** As a data engineer, I want feature vectors ordered exactly as the model expects, so that predictions are not corrupted by feature position mismatches.

#### Acceptance Criteria

1. WHEN constructing Feature_Vector for Model1_Risk, THE Spring_Boot_Backend SHALL order features according to model1_feature_cols.joblib sequence
2. WHEN constructing Feature_Vector for Model3_Recommendation, THE Spring_Boot_Backend SHALL order features according to model1_feature_cols.joblib sequence (shared feature space)
3. THE FastAPI_AI_Service SHALL validate that incoming Feature_Vector length matches expected feature count
4. THE FastAPI_AI_Service SHALL validate that Feature_Vector column names match model.feature_names_in_ attribute
5. IF Feature_Vector order or naming does not match loaded Artifact, THEN THE FastAPI_AI_Service SHALL return error response with detailed mismatch description

### Requirement 7: Target Leakage Elimination

**User Story:** As a data scientist, I want to ensure prediction features do not contain outcome variables, so that model predictions are valid and unbiased.

#### Acceptance Criteria

1. THE Spring_Boot_Backend SHALL NOT include credit_defaulted field in Feature_Vector when user has no defaulted debts
2. THE Spring_Boot_Backend SHALL NOT include credit_defaulted field in Feature_Vector when predicting future risk
3. WHERE credit_defaulted represents known historical outcome, THE System SHALL exclude it from prediction features
4. THE Development Team SHALL document any features that may leak future information and implement guards

### Requirement 8: Historical Data Validation for Forecasting

**User Story:** As a forecasting analyst, I want Prophet models to receive sufficient historical data, so that predictions are statistically reliable.

#### Acceptance Criteria

1. WHEN building expense history for Model2_Forecast, THE Spring_Boot_Backend SHALL query Expense entities for at least 3 months of history
2. IF fewer than 3 months of Expense history exist, THEN THE System SHALL return Inference_Source=INSUFFICIENT_HISTORY
3. THE Model2_Forecast service SHALL validate that Prophet models were trained on sufficient data (recommended minimum 12 months)
4. WHERE training data is insufficient, THE Development Team SHALL document forecasting limitations in model documentation
5. THE Model2_Forecast service SHALL NOT generate forecast predictions from fewer than 3 historical data points

### Requirement 9: Recommendation Category from Model Prediction

**User Story:** As a financial advisor, I want recommendation categories determined by ML model output, so that advice is personalized to user financial patterns.

#### Acceptance Criteria

1. WHEN generating recommendations, THE Model3_Recommendation service SHALL invoke XGBoost model.predict() with Feature_Vector
2. THE Model3_Recommendation service SHALL map predicted class index to recommendation category using model3_recommendation_label_map.joblib
3. THE Model3_Recommendation service SHALL use Artifact-loaded thresholds only for fallback rule logic when ML_Model is unavailable
4. THE Model3_Recommendation service SHALL NOT duplicate threshold values (debt_to_income_high=0.1314, savings_ratio_low=0.05, expense_to_income_high=0.85, per_capita_income_low=10000) in source code
5. WHERE ML_Model prediction succeeds, THE Model3_Recommendation service SHALL set Inference_Source=ML_MODEL regardless of feature values

### Requirement 10: Response Source Tracking

**User Story:** As a system administrator, I want prediction responses to indicate their source, so that I can monitor ML model usage and fallback frequency.

#### Acceptance Criteria

1. THE Spring_Boot_Backend SHALL add inference_source field to FinancialRiskResponse DTO
2. THE Spring_Boot_Backend SHALL add inference_source field to ForecastResponse DTO
3. THE Spring_Boot_Backend SHALL add inference_source field to RecommendationResponse DTO
4. THE FastAPI_AI_Service SHALL populate inference_source field in all prediction responses
5. WHERE prediction uses ML_Model, THE System SHALL set inference_source=ML_MODEL
6. WHERE prediction uses fallback rules, THE System SHALL set inference_source=RULE_FALLBACK
7. WHERE data is insufficient, THE System SHALL set inference_source=INSUFFICIENT_DATA
8. WHERE model artifact is unavailable, THE System SHALL set inference_source=MODEL_UNAVAILABLE
9. WHERE feature validation fails, THE System SHALL set inference_source=INVALID_FEATURES
10. THE System SHALL log inference_source value for monitoring and analytics

### Requirement 11: Preserve Frozen Architecture

**User Story:** As a project manager, I want changes to preserve existing architecture, so that integration with deployed systems is not broken.

#### Acceptance Criteria

1. THE System SHALL maintain the Flutter → Spring_Boot_Backend → FastAPI_AI_Service → ML_Model request flow
2. THE System SHALL NOT modify existing REST API endpoint paths or HTTP methods
3. THE System SHALL preserve existing JSON request and response schema structures (with addition of inference_source field)
4. THE System SHALL NOT replace trained model Artifact files during this implementation
5. THE System SHALL NOT introduce new microservices or architectural components

### Requirement 12: Integration Testing Requirements

**User Story:** As a QA engineer, I want comprehensive tests validating real data flow, so that production deployments are reliable.

#### Acceptance Criteria

1. THE Test Suite SHALL verify Model1_Risk loads model1_financial_risk_xgb.joblib successfully
2. THE Test Suite SHALL verify Model2_Forecast loads all three Prophet models successfully
3. THE Test Suite SHALL verify Model3_Recommendation loads model3_recommendation_xgb.joblib successfully
4. THE Test Suite SHALL verify predictions use model.predict() by checking Inference_Source=ML_MODEL
5. THE Test Suite SHALL verify different Feature_Vector inputs produce different model outputs
6. THE Test Suite SHALL verify INSUFFICIENT_DATA status when required Database_Entity records are missing
7. THE Test Suite SHALL verify Flutter_Frontend displays error UI when Inference_Source is not ML_MODEL
8. THE Test Suite SHALL execute full integration tests from Flutter_Frontend through FastAPI_AI_Service
9. THE Test Suite SHALL verify Feature_Vector construction queries actual Database_Entity records
10. THE Test Suite SHALL verify no Hardcoded_Value substitution occurs during successful predictions

### Requirement 13: Fallback Logic Constraints

**User Story:** As a reliability engineer, I want fallback logic isolated from normal prediction flow, so that temporary errors do not corrupt ML predictions.

#### Acceptance Criteria

1. THE FastAPI_AI_Service SHALL only execute fallback calculations when ML_Model is unavailable at initialization
2. THE FastAPI_AI_Service SHALL NOT execute fallback calculations during normal operation when ML_Model is loaded
3. WHERE fallback logic executes, THE System SHALL set Inference_Source to RULE_FALLBACK or MODEL_UNAVAILABLE
4. THE Spring_Boot_Backend SHALL NOT generate synthetic Feature_Vector values when Database_Entity data is missing
5. THE System SHALL prefer explicit error responses over fallback synthetic predictions

### Requirement 14: Database Query Optimization

**User Story:** As a performance engineer, I want feature construction to execute efficiently, so that prediction latency remains acceptable.

#### Acceptance Criteria

1. WHEN querying Income entities, THE Spring_Boot_Backend SHALL use date range filtering (start_of_month, end_of_month) to limit result set
2. WHEN querying Expense entities, THE Spring_Boot_Backend SHALL use date range filtering (start_of_month, end_of_month) to limit result set
3. WHEN querying Debt entities, THE Spring_Boot_Backend SHALL filter by status=ACTIVE to exclude closed accounts
4. THE Spring_Boot_Backend SHALL execute Database_Entity queries in parallel where dependencies allow
5. THE Spring_Boot_Backend SHALL cache UserProfile data within a single prediction request to avoid duplicate queries

### Requirement 15: Documentation and Maintainability

**User Story:** As a new developer, I want clear documentation explaining data flow, so that I can understand and modify the system.

#### Acceptance Criteria

1. THE Development Team SHALL document Feature_Vector construction logic in code comments
2. THE Development Team SHALL document Artifact file purpose and structure in model directory README
3. THE Development Team SHALL document Inference_Source enumeration values and meanings in API documentation
4. THE Development Team SHALL document minimum data requirements for each ML_Model in system documentation
5. WHERE business rules are required (e.g., Model3 fallback thresholds), THE Development Team SHALL document rationale in code comments
