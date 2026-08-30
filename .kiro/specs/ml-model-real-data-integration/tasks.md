# Implementation Plan: ML Model Real Data Integration

## Overview

This implementation plan converts the technical design into concrete coding tasks to eliminate hardcoded assumptions and integrate ML model artifacts with real user data. The implementation follows the existing architecture (Flutter → Spring Boot → FastAPI) and ensures all predictions originate from trained ML models using database-queried features, with explicit error handling when data is insufficient.

## Tasks

- [x] 1. Update Spring Boot DTOs with inference_source field
  - Add `inferenceSource` field to `FinancialRiskResponse` DTO
  - Add `inferenceSource` field to `ExpenseForecastResponse` DTO
  - Add `inferenceSource` field to `AiRecommendationResponse` DTO
  - Create `InferenceSource` enum with values: ML_MODEL, INSUFFICIENT_DATA, INVALID_FEATURES, MODEL_UNAVAILABLE, INSUFFICIENT_HISTORY, RULE_FALLBACK
  - _Requirements: 6.1, 6.2, 6.3, 10.1, 10.2, 10.3_- [x] 2. Implement database-driven feature construction in Spring Boot
  - [x] 2.1 Refactor buildModel1Features method to query database entities
    - Remove all hardcoded demographic defaults (age=35, gender=1, education=2, maritalStatus=1)
    - Remove all hardcoded income defaults (totalIncome=50000, employmentIncome)
    - Remove all hardcoded expense defaults (totalExp, foodExp)
    - Remove all hardcoded credit defaults (creditScore=650, credit_clv=0, etc.)
    - Query UserProfile entity for demographic data (age, gender, education, maritalStatus, householdSize, dependentsCount, creditScore)
    - Query Income entities with date range filter (current month) for income breakdown
    - Query Expense entities with date range filter (current month) for expense breakdown
    - Query Debt entities filtered by status=ACTIVE for debt obligations
    - Query Savings entities for total savings balance
    - Calculate derived features (expense_to_income_ratio, debt_to_income_ratio, financial_surplus, savings_ratio, per_capita_income, employment_capacity)
    - Return null or throw InsufficientDataException when required entities are missing
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 14.1, 14.2, 14.3_

  - [x] 2.2 Write unit tests for buildModel1Features
    - Test with complete database entities returns correct 42-feature vector
    - Test with missing UserProfile returns null/exception
    - Test with no Income records uses UserProfile.monthlyIncome fallback
    - Test with no Income and no Profile fallback returns null/exception
    - Test feature order matches model1_feature_cols.joblib specification
    - Test derived feature calculations (ratios, surplus, per capita income)
    - _Requirements: 2.6, 6.1, 12.9_

- [x] 3. Implement expense history construction in Spring Boot
  - [x] 3.1 Refactor buildExpenseHistory method
    - Query Expense entities for at least 3 months of historical data
    - Aggregate expenses by month into food, non-food, and total categories
    - Sort records chronologically
    - Return null or throw InsufficientDataException when fewer than 3 months exist
    - _Requirements: 2.3, 8.1, 8.2, 8.5, 14.2_

  - [x] 3.2 Write unit tests for buildExpenseHistory
    - Test with 6 months of data returns correct list of MonthlyExpenseRecords
    - Test records are chronologically sorted
    - Test total = food + nonFood for each record
    - Test with only 2 months returns null/exception
    - _Requirements: 8.1, 8.5, 12.9_

- [x] 4. Implement feature validation in Spring Boot
  - [x] 4.1 Create feature validation service
    - Validate feature vector length equals 42
    - Validate all features have non-null values
    - Validate feature names match model1_feature_cols.joblib order
    - Return validation result with detailed error messages on mismatch
    - _Requirements: 2.7, 6.3, 6.4_

  - [x] 4.2 Write unit tests for feature validation
    - Test valid 42-feature vector passes validation
    - Test 40-feature vector fails with length mismatch error
    - Test feature vector with null values fails validation
    - Test feature name order validation
    - _Requirements: 6.3, 6.4_

- [x] 5. Update AiServiceImpl orchestration logic
  - [x] 5.1 Refactor runFullAnalysis method
    - Call buildModel1Features and validate result is not null
    - Call buildExpenseHistory and validate result is not null
    - Call feature validation service before invoking FastAPI
    - Return AiAnalysisResponse with inferenceSource=INSUFFICIENT_DATA when validation fails
    - Only call FastAPI endpoint when all validations pass
    - Handle FastAPI connection failures and return inferenceSource=MODEL_UNAVAILABLE
    - _Requirements: 2.7, 2.8, 5.1, 5.2, 5.6, 12.6_

  - [x] 5.2 Write unit tests for runFullAnalysis
    - Test with complete data calls FastAPI and returns ML_MODEL response
    - Test with insufficient data returns INSUFFICIENT_DATA without calling FastAPI
    - Test with FastAPI failure returns MODEL_UNAVAILABLE
    - _Requirements: 5.1, 5.2, 5.6, 12.6_

- [x] 6. Checkpoint - Ensure Spring Boot changes compile and tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Refactor FastAPI RiskService artifact loading
  - [x] 7.1 Update load_artifacts method
    - Load model1_financial_risk_xgb.joblib XGBoost model
    - Load model1_feature_cols.joblib feature column list
    - Load model1_label_map.joblib risk level label mapping
    - Set self.model = None and log MODEL_UNAVAILABLE if any artifact file is missing
    - Validate loaded feature_cols length equals 42
    - _Requirements: 3.1, 3.2, 3.3, 3.10_

  - [x] 7.2 Write unit tests for RiskService artifact loading
    - Test successful loading when all artifact files present
    - Test self.model is None when model file missing
    - Test log contains MODEL_UNAVAILABLE when loading fails
    - Test feature_cols length equals 42
    - _Requirements: 3.1, 3.2, 3.3, 12.1_

- [x] 8. Implement ML model prediction in RiskService
  - [x] 8.1 Refactor predict method
    - Validate feature vector length matches len(self.feature_cols)
    - Validate feature names match model.feature_names_in_
    - Return error response with inferenceSource=INVALID_FEATURES if validation fails
    - Return error response with inferenceSource=MODEL_UNAVAILABLE if self.model is None
    - Invoke model.predict_proba() when validations pass
    - Map predicted class index to risk level using label_map
    - Set inferenceSource=ML_MODEL in response
    - _Requirements: 4.1, 4.2, 4.7, 5.3, 6.3, 6.4, 6.5_

  - [x] 8.2 Write unit tests for RiskService predict
    - Test with valid 42-feature input returns valid risk level and ML_MODEL source
    - Test with 40-feature input returns INVALID_FEATURES error
    - Test with self.model=None returns MODEL_UNAVAILABLE error
    - Test model.predict_proba() is called exactly once
    - _Requirements: 4.1, 4.7, 5.3, 12.4_

- [x] 9. Refactor FastAPI ForecastService artifact loading
  - [x] 9.1 Update load_artifacts method
    - Load model2_food_prophet.joblib Prophet model
    - Load model2_nonfood_prophet.joblib Prophet model
    - Load model2_total_prophet.joblib Prophet model
    - Load model2_forecast_config.joblib configuration
    - Set all models to None and log MODEL_UNAVAILABLE if any artifact missing
    - _Requirements: 3.4, 3.5, 3.10_

  - [x] 9.2 Write unit tests for ForecastService artifact loading
    - Test all three Prophet models load successfully when files present
    - Test models set to None when files missing
    - _Requirements: 3.4, 3.5, 12.2_

- [x] 10. Remove hardcoded values from ForecastService
  - [x] 10.1 Refactor forecast method
    - Remove hardcoded training baselines (train_base_food=5300, train_base_nf=82000, train_base_tot=87300)
    - Remove hardcoded inflation_rate=0.005 from fallback logic
    - Remove hardcoded seasonal_factor_f and seasonal_factor_nf from fallback logic
    - Validate len(history) >= 3 before processing
    - Return ForecastResponse with inferenceSource=INSUFFICIENT_HISTORY if validation fails
    - Return error response with inferenceSource=MODEL_UNAVAILABLE if models are None
    - Invoke Prophet model.predict() for each expense category when validations pass
    - Set inferenceSource=ML_MODEL when Prophet predictions succeed
    - _Requirements: 1.5, 1.6, 1.7, 4.3, 4.4, 4.5, 5.4, 8.2, 8.5_

  - [x] 10.2 Write unit tests for ForecastService forecast
    - Test with 6 months history returns 6 forecast points with ML_MODEL source
    - Test with 2 months history returns INSUFFICIENT_HISTORY error
    - Test with models=None returns MODEL_UNAVAILABLE error
    - Test Prophet model.predict() called for each category
    - _Requirements: 4.3, 4.4, 4.5, 5.4, 8.5, 12.4_

- [x] 11. Refactor FastAPI RecommendationService artifact loading
  - [x] 11.1 Update load_artifacts method
    - Load model3_recommendation_xgb.joblib XGBoost model
    - Load model3_recommendation_label_map.joblib label mapping
    - Load model3_recommendation_thresholds.joblib threshold values
    - Load model3_recommendation_text.joblib recommendation text templates
    - Set self.model = None and log MODEL_UNAVAILABLE if any artifact missing
    - _Requirements: 3.6, 3.7, 3.8, 3.9, 3.10_

  - [x] 11.2 Write unit tests for RecommendationService artifact loading
    - Test successful loading when all artifacts present
    - Test self.model is None when model file missing
    - _Requirements: 3.6, 3.7, 3.8, 3.9, 12.3_

- [x] 12. Remove hardcoded thresholds from RecommendationService
  - [x] 12.1 Refactor generate method
    - Remove duplicated threshold values from source code (debt_to_income_high=0.1314, savings_ratio_low=0.05, etc.)
    - Prioritize model.predict() when self.model is not None
    - Map predicted class to recommendation category using label_map
    - Set inferenceSource=ML_MODEL when XGBoost prediction succeeds
    - Only execute fallback logic when self.model is None (set inferenceSource=RULE_FALLBACK)
    - _Requirements: 1.8, 1.9, 4.6, 9.1, 9.2, 9.3, 9.5, 13.1, 13.2_

  - [x] 12.2 Refactor _generate_rule_fallback method
    - Reference self.thresholds loaded from artifact exclusively
    - Remove all hardcoded threshold constants from code
    - Set inferenceSource=RULE_FALLBACK in response
    - _Requirements: 1.8, 9.4, 13.3_

  - [x] 12.3 Write unit tests for RecommendationService generate
    - Test with valid features and loaded model returns ML_MODEL prediction
    - Test with self.model=None uses rule fallback with RULE_FALLBACK source
    - Test thresholds come from self.thresholds artifact, not hardcoded values
    - _Requirements: 4.6, 9.1, 9.5, 12.4_

- [x] 13. Update FastAPI response schemas
  - [x] 13.1 Add inference_source field to response models
    - Add `inference_source` to RiskPredictionResponse schema
    - Add `inference_source` to ForecastResponse schema
    - Add `inference_source` to RecommendationResponse schema
    - Populate field in all service responses
    - _Requirements: 5.6, 10.4_

  - [x] 13.2 Write unit tests for response schema updates
    - Test all response schemas include inference_source field
    - Test inference_source populates correctly for each error state
    - _Requirements: 5.6, 10.4, 10.10_

- [x] 14. Checkpoint - Ensure FastAPI changes pass tests
  - Ensure all tests pass, ask the user if questions arise.

- [x] 15. Update Flutter frontend error handling
  - [x] 15.1 Update RiskCard widget
    - Check risk.inferenceSource value
    - Display error UI when inferenceSource != ML_MODEL
    - Show "Complete your profile" prompt when inferenceSource == INSUFFICIENT_DATA
    - Show "Service unavailable" message when inferenceSource == MODEL_UNAVAILABLE
    - _Requirements: 5.7, 5.8, 5.9_

  - [x] 15.2 Update ForecastChart widget
    - Check forecast.inferenceSource value
    - Display error message when inferenceSource != ML_MODEL
    - Show "Add 3 months of expenses" prompt when inferenceSource == INSUFFICIENT_HISTORY
    - _Requirements: 5.7_

  - [x] 15.3 Update RecommendationCard widget
    - Check recommendation.inferenceSource value
    - Display appropriate error message or prompt based on inferenceSource
    - Add disclaimer "Based on general guidelines" when inferenceSource == RULE_FALLBACK
    - _Requirements: 5.7, 5.8, 5.9_

  - [x] 15.4 Write widget tests for error handling
    - Test RiskCard displays error UI for non-ML_MODEL sources
    - Test ForecastChart displays INSUFFICIENT_HISTORY prompt
    - Test RecommendationCard displays RULE_FALLBACK disclaimer
    - _Requirements: 5.7, 12.7_

- [x] 16. Add logging for inference source tracking
  - [x] 16.1 Add logging in Spring Boot
    - Log feature construction start and completion
    - Log validation failures with details
    - Log FastAPI request failures
    - Log inferenceSource value for all responses
    - _Requirements: 10.10_

  - [x] 16.2 Add logging in FastAPI services
    - Log artifact loading success/failure at initialization
    - Log model prediction success/failure
    - Log feature validation errors with mismatch details
    - Log inferenceSource value for all responses
    - _Requirements: 10.10_

- [x] 17. Remove Target Leakage from feature construction
  - [x] 17.1 Update feature construction logic
    - Ensure credit_defaulted field is NOT included when user has no defaulted debts
    - Ensure credit_defaulted field is NOT included when predicting future risk
    - Add validation to prevent outcome variables from appearing in feature vectors
    - Document any features that may leak future information
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [x] 17.2 Write unit tests for target leakage prevention
    - Test credit_defaulted excluded from features when no defaults exist
    - Test credit_defaulted excluded when predicting future outcomes
    - _Requirements: 7.1, 7.2, 7.3_

- [x] 18. Integration testing
  - [x] 18.1 Write end-to-end integration tests
    - Test full flow from Flutter through Spring Boot to FastAPI with complete data
    - Test Model1 loads and returns ML_MODEL predictions
    - Test Model2 loads and returns ML_MODEL forecasts
    - Test Model3 loads and returns ML_MODEL recommendations
    - Test different feature vectors produce different model outputs
    - Test INSUFFICIENT_DATA response when database entities missing
    - Test Flutter displays error UI for non-ML_MODEL sources
    - Test no hardcoded value substitution occurs during successful predictions
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9, 12.10_

- [x] 19. Documentation updates
  - [x] 19.1 Add code comments and documentation
    - Document feature vector construction logic in AiServiceImpl
    - Document artifact file purpose and structure in model directory README
    - Document InferenceSource enum values and meanings in API documentation
    - Document minimum data requirements for each ML model in system docs
    - Document business rule rationale for Model3 fallback thresholds
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 20. Final checkpoint - Full system validation
  - Ensure all tests pass, ask the user if questions arise.ise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at reasonable breakpoints
- Testing tasks validate database-driven features and ML model integration
- All hardcoded values must be removed and replaced with database queries or artifact loading
- Feature order consistency (model1_feature_cols.joblib) is critical for correct predictions
- Error handling ensures explicit feedback rather than silent fallback to synthetic data

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1", "3.1", "4.1", "7.1", "9.1", "11.1"] },
    { "id": 2, "tasks": ["2.2", "3.2", "4.2", "7.2", "9.2", "11.2"] },
    { "id": 3, "tasks": ["5.1", "8.1", "10.1", "12.1", "12.2"] },
    { "id": 4, "tasks": ["5.2", "8.2", "10.2", "12.3", "13.1", "17.1"] },
    { "id": 5, "tasks": ["13.2", "17.2"] },
    { "id": 6, "tasks": ["15.1", "15.2", "15.3", "16.1", "16.2"] },
    { "id": 7, "tasks": ["15.4", "18.1", "19.1"] }
  ]
}
```
