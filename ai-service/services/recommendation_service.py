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

            logger.info("Loaded Model 3 Recommendation artifacts successfully.")

        except Exception as e:
            logger.error(f"Error loading Model 3 Recommendation artifacts: {e}", exc_info=True)

    def generate(self, 
                 risk_level: str = "Medium Risk",
                 health_score: float = 60.0,
                 top_driver: str = "expense_to_income_ratio",
                 features: Optional[Dict[str, Any]] = None) -> RecommendationResponse:
        
        category = "Expense Optimization"

        # Check features against Model 3 decision thresholds
        if features:
            d2i = float(features.get("debt_to_income_ratio", 0.0))
            e2i = float(features.get("expense_to_income_ratio", 0.0))
            savings_ratio = float(features.get("savings_ratio", 0.0))
            per_capita = float(features.get("per_capita_income", 25000.0))

            d2i_high = self.thresholds.get("debt_to_income_high", 0.15)
            savings_low = self.thresholds.get("savings_ratio_low", 0.05)
            e2i_high = self.thresholds.get("expense_to_income_high", 0.85)
            per_capita_low = self.thresholds.get("per_capita_income_low", 10000.0)

            if d2i >= d2i_high and d2i > 0:
                category = "Debt Reduction Plan"
            elif savings_ratio <= savings_low:
                category = "Build Emergency Savings"
            elif e2i >= e2i_high:
                category = "Expense Optimization"
            elif per_capita <= per_capita_low:
                category = "Increase Income / Employment Support"
            elif risk_level == "Low Risk" and health_score >= 75.0:
                category = "Maintain & Grow Wealth"
            else:
                category = "Expense Optimization"
        else:
            if "debt" in top_driver.lower():
                category = "Debt Reduction Plan"
            elif "savings" in top_driver.lower():
                category = "Build Emergency Savings"
            elif risk_level == "Low Risk" or health_score >= 80:
                category = "Maintain & Grow Wealth"
            elif "income" in top_driver.lower() and "ratio" not in top_driver.lower():
                category = "Increase Income / Employment Support"
            else:
                category = "Expense Optimization"

        template = DEFAULT_RECOMMENDATION_MESSAGES.get(category, DEFAULT_RECOMMENDATION_MESSAGES["Expense Optimization"])
        rec_text = template["text"]
        action_items = template["actions"]

        return RecommendationResponse(
            category=category,
            topDriver=top_driver,
            recommendation=rec_text,
            actionItems=action_items
        )
