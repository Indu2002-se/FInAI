import os
import logging
import joblib
import pandas as pd
import numpy as np
from typing import Dict, Any, List, Optional
from schemas import RecommendationResponse

logger = logging.getLogger("finai-ai.recommendation")

DEFAULT_RECOMMENDATION_MESSAGES = {
    "Debt Reduction Plan": {
        "text": "Your debt-to-income ratio is currently high. We recommend prioritizing high-interest debt repayment using the debt avalanche or debt snowball method before expanding non-essential spending.",
        "actions": [
            "List all outstanding debts ordered by highest interest rate.",
            "Allocate an extra 10-15% of surplus income to high-priority balances.",
            "Avoid creating new unsecured debt obligations."
        ]
    },
    "Build Emergency Savings": {
        "text": "Your liquid emergency reserves are below the recommended 3 to 6 months of living expenses. Establishing a dedicated emergency fund will protect you from financial vulnerability.",
        "actions": [
            "Set a target emergency fund equal to 3 months of essential expenses.",
            "Automate a recurring transfer of 10% from every paycheck into your savings account.",
            "Keep emergency funds in a high-yield, low-risk account."
        ]
    },
    "Expense Optimization": {
        "text": "Your monthly expenditures are consuming a large fraction of your income. Trimming non-essential discretionary expenses and negotiating recurring bills can free up significant monthly cash flow.",
        "actions": [
            "Review discretionary spending across dining, entertainment, and subscriptions.",
            "Set category budget limits and review weekly spending.",
            "Aim to reduce monthly non-essential expenses by 15%."
        ]
    },
    "Increase Income / Employment Support": {
        "text": "Your per-capita income relative to household size suggests potential benefit from supplemental income streams or career upskilling opportunities.",
        "actions": [
            "Explore supplementary or part-time revenue opportunities.",
            "Review eligible government or community benefits and tax credits.",
            "Consider skill development programs to enhance primary earning capacity."
        ]
    },
    "Maintain & Grow Wealth": {
        "text": "You have a strong financial profile with low risk, healthy savings, and manageable debt. Continue your disciplined approach and consider long-term wealth growth opportunities.",
        "actions": [
            "Maintain your healthy monthly savings and investment rate.",
            "Periodically rebalance your investment portfolio and asset allocation.",
            "Review insurance and retirement plans to protect existing wealth."
        ]
    }
}

class RecommendationService:
    def __init__(self, models_dir: str):
        self.models_dir = models_dir
        self.model = None
        self.feature_cols = []
        self.label_map = {}
        self.inv_label_map = {}
        self.thresholds = {}
        self.rec_text = {}
        self.load_artifacts()

    def load_artifacts(self):
        try:
            model_path = os.path.join(self.models_dir, "model3_recommendation_xgb.joblib")
            lmap_path = os.path.join(self.models_dir, "model3_recommendation_label_map.joblib")
            thresh_path = os.path.join(self.models_dir, "model3_recommendation_thresholds.joblib")
            text_path = os.path.join(self.models_dir, "model3_recommendation_text.joblib")
            cols_path = os.path.join(self.models_dir, "model1_feature_cols.joblib")

            if os.path.exists(cols_path):
                self.feature_cols = joblib.load(cols_path)

            if os.path.exists(lmap_path):
                raw_map = joblib.load(lmap_path)
                if isinstance(raw_map, dict) and "rec_label_map" in raw_map:
                    self.label_map = raw_map["rec_label_map"]
                else:
                    self.label_map = raw_map
                self.inv_label_map = {v: k for k, v in self.label_map.items()}

            if os.path.exists(thresh_path):
                self.thresholds = joblib.load(thresh_path)

            if os.path.exists(text_path):
                self.rec_text = joblib.load(text_path)

            if os.path.exists(model_path):
                self.model = joblib.load(model_path)
                # Fallback for feature_cols if not loaded from file
                if not self.feature_cols and hasattr(self.model, "feature_names_in_"):
                    self.feature_cols = list(self.model.feature_names_in_)

            logger.info("Loaded Model 3 Recommendation artifacts successfully. Model=%s, Features=%d",
                        type(self.model).__name__ if self.model else "None", len(self.feature_cols))

        except Exception as e:
            logger.error(f"Error loading Model 3 Recommendation artifacts: {e}", exc_info=True)

    def build_feature_vector(self, raw_features: Dict[str, Any]) -> pd.DataFrame:
        row = {}
        for col in self.feature_cols:
            val = raw_features.get(col, 0.0) if raw_features else 0.0
            if val is None:
                val = 0.0
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

    def generate(self, 
                 risk_level: str = "Medium Risk",
                 health_score: float = 60.0,
                 top_driver: str = "expense_to_income_ratio",
                 features: Optional[Dict[str, Any]] = None) -> RecommendationResponse:
        
        category = None
        inference_source = "RULE_FALLBACK"

        # 1. Attempt REAL XGBoost Model 3 Prediction
        if self.model is not None and features is not None and len(self.feature_cols) > 0:
            try:
                df = self.build_feature_vector(features)
                pred_classes = self.model.predict(df)
                pred_class_idx = int(pred_classes[0])
                predicted_category = self.inv_label_map.get(pred_class_idx)
                
                if predicted_category:
                    category = predicted_category
                    inference_source = "ML_MODEL"
                    logger.info("[ML_MODEL] Model 3 XGBoost inference succeeded: predicted class %d -> '%s'",
                                pred_class_idx, category)
            except Exception as e:
                logger.warning("Model 3 XGBoost prediction failed (%s). Using rule fallback.", e)

        # 2. Safety / Fallback Rule-Based Mechanism (Triggered only when ML model unavailable or failed)
        if category is None:
            inference_source = "RULE_FALLBACK"
            category = self._generate_rule_fallback(risk_level, health_score, top_driver, features)
            logger.info("[RULE_FALLBACK] Generated recommendation via threshold/domain rules: '%s'", category)

        # 3. Construct Recommendation Text and Action Items
        rec_text, action_items = self._build_recommendation_content(category, risk_level, health_score, top_driver)

        logger.info("Recommendation generated via %s for top_driver='%s' -> category='%s'",
                    inference_source, top_driver, category)

        return RecommendationResponse(
            category=category,
            topDriver=top_driver,
            recommendation=rec_text,
            actionItems=action_items
        )

    def _generate_rule_fallback(self,
                                risk_level: str,
                                health_score: float,
                                top_driver: str,
                                features: Optional[Dict[str, Any]]) -> str:
        """Deterministic safety baseline when ML Model 3 is unavailable."""
        if features:
            d2i = float(features.get("debt_to_income_ratio", 0.0) or 0.0)
            e2i = float(features.get("expense_to_income_ratio", 0.0) or 0.0)
            savings_ratio = float(features.get("savings_ratio", 0.0) or 0.0)
            per_capita = float(features.get("per_capita_income", 25000.0) or 25000.0)

            d2i_high = self.thresholds.get("debt_to_income_high", 0.1314)
            savings_low = self.thresholds.get("savings_ratio_low", 0.05)
            e2i_high = self.thresholds.get("expense_to_income_high", 0.85)
            per_capita_low = self.thresholds.get("per_capita_income_low", 10000.0)

            if d2i >= d2i_high and d2i > 0:
                return "Debt Reduction Plan"
            elif savings_ratio <= savings_low:
                return "Build Emergency Savings"
            elif e2i >= e2i_high:
                return "Expense Optimization"
            elif per_capita <= per_capita_low:
                return "Increase Income / Employment Support"
            elif risk_level == "Low Risk" and health_score >= 75.0:
                return "Maintain & Grow Wealth"
            else:
                return "Expense Optimization"
        else:
            top_lower = top_driver.lower() if top_driver else ""
            if "debt" in top_lower:
                return "Debt Reduction Plan"
            elif "savings" in top_lower:
                return "Build Emergency Savings"
            elif risk_level == "Low Risk" or health_score >= 80:
                return "Maintain & Grow Wealth"
            elif "income" in top_lower and "ratio" not in top_lower:
                return "Increase Income / Employment Support"
            else:
                return "Expense Optimization"

    def _build_recommendation_content(self,
                                      category: str,
                                      risk_level: str,
                                      health_score: float,
                                      top_driver: str) -> tuple[str, List[str]]:
        """Constructs detailed recommendation explanation and actionable steps."""
        template = DEFAULT_RECOMMENDATION_MESSAGES.get(category, DEFAULT_RECOMMENDATION_MESSAGES["Expense Optimization"])
        base_text = template["text"]
        actions = list(template["actions"])

        # Enhance text if training artifact text is available
        driver_desc = ""
        action_desc = ""
        if isinstance(self.rec_text, dict):
            driver_map = self.rec_text.get("driver_text", {})
            action_map = self.rec_text.get("action_text", {})
            driver_desc = driver_map.get(top_driver, "")
            action_desc = action_map.get(category, "")

        if driver_desc and action_desc:
            personalized_text = (
                f"Your profile is assessed as {risk_level} (Financial Health Score: {round(health_score)}/100), "
                f"driven mainly by {driver_desc}. Recommended focus: {category} — {action_desc}."
            )
            return personalized_text, actions

        return base_text, actions

