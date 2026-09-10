# FinAI Machine Learning Artifacts & Inference Specification

This directory contains the production-trained machine learning artifacts for the FinAI ecosystem (Spring Boot Backend, FastAPI AI Microservice, and Flutter Mobile Application).

---

## 1. Overview of Artifacts

| Model | Artifact File | Type | Description |
|---|---|---|---|
| **Model 1** | `model1_financial_risk_xgb.joblib` | XGBoost Classifier | Financial Risk & Health Score classifier (3-class: High, Medium, Low Risk). |
| **Model 1** | `model1_feature_cols.joblib` | List[str] | Canonical ordered list of the 42 required feature columns. |
| **Model 1** | `model1_label_map.joblib` | Dict[int, str] | Mapping of predicted class indices `{0: 'High Risk', 1: 'Medium Risk', 2: 'Low Risk'}`. |
| **Model 2** | `model2_food_prophet.joblib` | Prophet Model | Time-series forecasting model for monthly food expenditure. |
| **Model 2** | `model2_nonfood_prophet.joblib` | Prophet Model | Time-series forecasting model for monthly non-food expenditure. |
| **Model 2** | `model2_total_prophet.joblib` | Prophet Model | Time-series forecasting model for monthly total expenditure. |
| **Model 2** | `model2_forecast_config.joblib` | Dict | Prophet hyperparameters and baseline configuration. |
| **Model 3** | `model3_recommendation_xgb.joblib` | XGBoost Classifier | Recommendation strategy classifier (5 categories). |
| **Model 3** | `model3_recommendation_label_map.joblib` | Dict | Category mapping for recommendation outputs. |
| **Model 3** | `model3_recommendation_thresholds.joblib` | Dict | Quantile-derived thresholds for fallback business rules. |
| **Model 3** | `model3_recommendation_text.joblib` | Dict | Personalized template phrases and SHAP driver explanations. |

---

## 2. Canonical 41 Features (Model 1 & Model 3)

The 41 features must be constructed strictly from database entities (`UserProfile`, `Income`, `Expense`, `Debt`, `Savings`) in the exact canonical sequence specified below:

```python
[
    'age', 'gender', 'education', 'marital_status', 'household_size_f',
    'employment_income', 'other_income', 'windfall_income', 'agri_income',
    'non_agri_income', 'transfer_income', 'total_income', 'food_expenditure',
    'nonfood_expenditure', 'total_expenditure', 'expense_to_income_ratio',
    'financial_surplus', 'savings_ratio', 'per_capita_income', 'employment_capacity',
    'debt_amount', 'debt_records', 'debt_sources', 'debt_to_income_ratio',
    'credit_card_debt', 'has_credit_card_debt', 'has_creditmix_match',
    'credit_score', 'credit_clv', 'credit_fraud_txn',
    'cc_utilization_ratio', 'cc_late_payments', 'cc_credit_lines',
    'cc_debt_to_income_ratio', 'cc_total_spend_last_year', 'cc_avg_txn_amount',
    'cc_total_txns', 'cc_tenure_years', 'vehicle_ownership',
    'instalment_goods_flag', 'instalment_amount'
]
```

### Target Leakage Resolution:
- `credit_defaulted` previously encoded future loan default outcomes directly into input features. It was identified as target leakage and completely removed from the feature set and retraining pipelines of both Model 1 (Financial Risk) and Model 3 (Recommendations).
- Both models have been retrained on the leakage-free 41-feature set, achieving robust generalization (Model 1 accuracy ~83%, Model 3 accuracy ~99.8%).

---

## 3. Expense Forecasting (Model 2 Prophet)

- **Minimum History Requirement**: Requires $\ge 3$ distinct calendar months of historical expense records.
- **Output Horizon**: 3, 6, or 12 months ahead projection including predicted total, lower confidence bound, and upper confidence bound.
- **Zero Synthetic Fallbacks**: When history is $< 3$ months, the service returns empty lists with `inference_source="INSUFFICIENT_HISTORY"`.

---

## 4. Recommendation Strategy & Fallback Thresholds (Model 3)

Model 3 classifies users into 5 strategic action categories:
1. `Debt Reduction Plan`
2. `Build Emergency Savings`
3. `Expense Optimization`
4. `Increase Income / Employment Support`
5. `Maintain & Grow Wealth`

When Model 3 XGBoost is offline, the service falls back deterministically to `model3_recommendation_thresholds.joblib`:
- `debt_to_income_high`: D2I ratio threshold above which debt reduction is prioritized.
- `savings_ratio_low`: Savings ratio threshold below which emergency fund accumulation is prioritized.
- `expense_to_income_high`: High expense ratio prompting budget optimization.
- `per_capita_income_low`: Low per-capita threshold indicating income expansion needs.

---

## 5. InferenceSource Enum & Meaning

Every prediction response carries an explicit `inferenceSource` / `inference_source` tag:

| Value | Meaning | Client Behavior |
|---|---|---|
| `ML_MODEL` | Authentic prediction produced by trained ML artifact with database features. | Render standard charts, probability scores, SHAP explanations. |
| `INSUFFICIENT_DATA` | User has incomplete financial profile (missing UserProfile, Income, or Expenses). | Prompt user to complete financial onboarding profile. |
| `INSUFFICIENT_HISTORY` | User has fewer than 3 months of recorded expenses for Prophet forecasting. | Prompt user to log at least 3 months of expenses. |
| `INVALID_FEATURES` | Feature vector failed validation (length != 41 or null values). | Display data formatting error notification. |
| `MODEL_UNAVAILABLE` | ML microservice offline or joblib artifact file missing. | Display "Service temporarily unavailable". |
| `RULE_FALLBACK` | Offline deterministic rule fallback based on artifact thresholds. | Display "Based on general guidelines (AI Model Offline)" badge. |
