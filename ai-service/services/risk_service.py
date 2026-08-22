import os
import logging
import numpy as np
import pandas as pd
import joblib
from typing import Dict, Any, Tuple, List
from schemas import RiskPredictionResponse, RiskExplanation, RiskDriver

logger = logging.getLogger("finai-ai.risk")

# Human-readable labels and descriptions for features
FEATURE_METADATA = {
    "expense_to_income_ratio": {
        "readable": "Expense-to-Income Ratio",
        "description": "Portion of your monthly income spent on household expenses."
    },
    "financial_surplus": {
        "readable": "Financial Surplus",
        "description": "Remaining income available after covering all living expenses."
    },
    "debt_to_income_ratio": {
        "readable": "Debt-to-Income Ratio",
        "description": "Total debt obligations relative to your regular income."
    },
    "savings_ratio": {
        "readable": "Savings Ratio",
        "description": "Rate of monthly income dedicated to savings reserves."
    },
    "total_income": {
        "readable": "Total Monthly Income",
        "description": "Aggregate household earnings from all sources."
    },
    "total_expenditure": {
        "readable": "Total Household Expenditure",
        "description": "Total monthly spending across food and essential services."
    },
    "debt_amount": {
        "readable": "Total Debt Obligations",
        "description": "Total outstanding loans, borrowings, or credit balances."
    },
    "credit_score": {
        "readable": "Credit Score",
        "description": "Indicator of repayment history and credit reliability."
    },
    "cc_utilization_ratio": {
        "readable": "Credit Card Utilization",
        "description": "Percentage of available revolving credit lines utilized."
    },
    "employment_income": {
        "readable": "Employment Earnings",
        "description": "Consistent primary salary or wage income."
    },
    "food_expenditure": {
        "readable": "Food & Grocery Expenses",
        "description": "Monthly spending allocated to groceries and nutrition."
    },
    "nonfood_expenditure": {
        "readable": "Non-Food & Utility Expenses",
        "description": "Monthly spending on utilities, education, transport, and other services."
    },
    "household_size_f": {
        "readable": "Household Size",
        "description": "Number of family members dependent on the household budget."
    },
    "per_capita_income": {
        "readable": "Per-Capita Income",
        "description": "Income distributed across individual household members."
    }
}

class RiskService:
    def __init__(self, models_dir: str):
        self.models_dir = models_dir
        self.model = None
        self.feature_cols = []
        self.label_map = {}
        self.inv_label_map = {}
        self.shap_explainer = None
        self.load_artifacts()

    def load_artifacts(self):
        try:
            model_path = os.path.join(self.models_dir, "model1_financial_risk_xgb.joblib")
            cols_path = os.path.join(self.models_dir, "model1_feature_cols.joblib")
            label_path = os.path.join(self.models_dir, "model1_label_map.joblib")

            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model 1 artifact not found at {model_path}")

            self.model = joblib.load(model_path)
            self.feature_cols = joblib.load(cols_path)
            self.label_map = joblib.load(label_path)
            self.inv_label_map = {v: k for k, v in self.label_map.items()}

            logger.info(f"Loaded Model 1 with {len(self.feature_cols)} feature columns. Labels: {self.label_map}")

            # Initialize SHAP explainer if available
            try:
                import shap
                self.shap_explainer = shap.TreeExplainer(self.model)
                logger.info("Initialized SHAP TreeExplainer for Model 1.")
            except Exception as e:
                logger.warning(f"SHAP TreeExplainer initialization deferred/skipped: {e}")

        except Exception as e:
            logger.error(f"Error loading Model 1 artifacts: {e}", exc_info=True)
            raise

    def build_feature_vector(self, raw_features: Dict[str, Any]) -> pd.DataFrame:
        row = {}
        for col in self.feature_cols:
            val = raw_features.get(col, 0.0)
            if val is None:
                val = 0.0
            # Handle categorical / numeric conversions
            if isinstance(val, bool):
                val = 1.0 if val else 0.0
            elif isinstance(val, (int, float)):
                val = float(val)
            else:
                try:
                    val = float(val)
                except (ValueError, TypeError):
                    val = 0.0
            row[col] = val
        return pd.DataFrame([row], columns=self.feature_cols)

    def predict(self, raw_features: Dict[str, Any]) -> RiskPredictionResponse:
        df = self.build_feature_vector(raw_features)
        
        # Predict probabilities
        probabilities = self.model.predict_proba(df)[0]
        pred_class_idx = int(np.argmax(probabilities))
        risk_level = self.inv_label_map.get(pred_class_idx, "Medium Risk")
        
        # Calculate Risk Probability (High risk class probability or weighted risk index)
        # Class 0: High Risk, Class 1: Medium Risk, Class 2: Low Risk
        high_risk_prob = float(probabilities[0]) if len(probabilities) > 0 else 0.5
        med_risk_prob = float(probabilities[1]) if len(probabilities) > 1 else 0.3
        low_risk_prob = float(probabilities[2]) if len(probabilities) > 2 else 0.2
        
        weighted_risk = (high_risk_prob * 1.0) + (med_risk_prob * 0.5) + (low_risk_prob * 0.0)
        risk_probability = round(weighted_risk, 4)
        
        # Financial Health Score: 0 to 100
        # High risk -> lower score; Low risk -> higher score
        health_score = round(max(5.0, min(100.0, (1.0 - weighted_risk) * 100.0)), 1)
        
        # Compute SHAP explanation
        explanation = self._compute_explanation(df)

        return RiskPredictionResponse(
            financialHealthScore=health_score,
            riskLevel=risk_level,
            riskProbability=risk_probability,
            explanation=explanation
        )

    def _compute_explanation(self, df: pd.DataFrame) -> RiskExplanation:
        drivers: List[RiskDriver] = []
        top_driver = "expense_to_income_ratio"

        try:
            if self.shap_explainer is not None:
                shap_values = self.shap_explainer.shap_values(df)
                if isinstance(shap_values, list):
                    # Multi-class: take contributions towards High Risk (class 0)
                    values = shap_values[0][0]
                elif len(shap_values.shape) == 3:
                    values = shap_values[0, :, 0]
                else:
                    values = shap_values[0]

                # Pair feature names with absolute impact
                feature_impacts = []
                for idx, col in enumerate(self.feature_cols):
                    impact_val = float(values[idx])
                    feature_impacts.append((col, impact_val, abs(impact_val)))

                feature_impacts.sort(key=lambda x: x[2], reverse=True)

                if feature_impacts:
                    top_driver = feature_impacts[0][0]

                for col, impact_val, abs_val in feature_impacts[:5]:
                    meta = FEATURE_METADATA.get(col, {
                        "readable": col.replace("_", " ").title(),
                        "description": f"Impacts your financial profile evaluation."
                    })
                    direction = "increases_risk" if impact_val > 0 else "decreases_risk"
                    drivers.append(RiskDriver(
                        feature=col,
                        impact=round(impact_val, 4),
                        direction=direction,
                        readableName=meta["readable"],
                        description=meta["description"]
                    ))
        except Exception as e:
            logger.warning(f"SHAP explanation fallback triggered: {e}")

        # Fallback if SHAP was unavailable or produced no drivers
        if not drivers:
            # Deterministic domain heuristics fallback
            row_dict = df.iloc[0].to_dict()
            e2i = row_dict.get("expense_to_income_ratio", 0.0)
            d2i = row_dict.get("debt_to_income_ratio", 0.0)
            surplus = row_dict.get("financial_surplus", 0.0)

            if e2i > 0.8:
                top_driver = "expense_to_income_ratio"
            elif d2i > 0.4:
                top_driver = "debt_to_income_ratio"
            elif surplus < 0:
                top_driver = "financial_surplus"
            else:
                top_driver = "savings_ratio"

            meta = FEATURE_METADATA.get(top_driver, {
                "readable": top_driver.replace("_", " ").title(),
                "description": "Key driver of your financial risk profile."
            })
            drivers.append(RiskDriver(
                feature=top_driver,
                impact=0.85,
                direction="increases_risk",
                readableName=meta["readable"],
                description=meta["description"]
            ))

        top_meta = FEATURE_METADATA.get(top_driver, {
            "readable": top_driver.replace("_", " ").title(),
            "description": ""
        })

        return RiskExplanation(
            topDriver=top_driver,
            topDriverReadable=top_meta["readable"],
            drivers=drivers
        )
