import os
import logging
import pandas as pd
import numpy as np
import joblib
from datetime import datetime
from dateutil.relativedelta import relativedelta
from typing import List, Dict, Any, Optional
from schemas import ForecastResponse, ForecastPoint, MonthlyExpenseRecord

logger = logging.getLogger("finai-ai.forecast")

class ForecastService:
    def __init__(self, models_dir: str):
        self.models_dir = models_dir
        self.food_model = None
        self.nonfood_model = None
        self.total_model = None
        self.forecast_config = {
            "future_periods": 6,
            "frequency": "MS"
        }
        self.load_artifacts()

    def load_artifacts(self):
        try:
            config_path = os.path.join(self.models_dir, "model2_forecast_config.joblib")
            food_path = os.path.join(self.models_dir, "model2_food_prophet.joblib")
            nonfood_path = os.path.join(self.models_dir, "model2_nonfood_prophet.joblib")
            total_path = os.path.join(self.models_dir, "model2_total_prophet.joblib")

            missing_files = []
            for path, name in [(config_path, "model2_forecast_config.joblib"),
                               (food_path, "model2_food_prophet.joblib"),
                               (nonfood_path, "model2_nonfood_prophet.joblib"),
                               (total_path, "model2_total_prophet.joblib")]:
                if not os.path.exists(path):
                    missing_files.append(name)

            if missing_files:
                logger.error(f"MODEL_UNAVAILABLE: Missing required Model 2 forecast artifacts: {', '.join(missing_files)}")
                self.food_model = None
                self.nonfood_model = None
                self.total_model = None
                return

            self.forecast_config = joblib.load(config_path)
            self.food_model = joblib.load(food_path)
            self.nonfood_model = joblib.load(nonfood_path)
            self.total_model = joblib.load(total_path)
            logger.info("Loaded all 3 Model 2 Prophet models (Food, Non-Food, Total) and forecast config.")

        except Exception as e:
            logger.error(f"MODEL_UNAVAILABLE: Error loading Model 2 forecast artifacts: {e}", exc_info=True)
            self.food_model = None
            self.nonfood_model = None
            self.total_model = None

    def forecast(self, history: List[MonthlyExpenseRecord], forecast_months: int = 6) -> ForecastResponse:
        # Check if models are available
        if self.food_model is None or self.nonfood_model is None or self.total_model is None:
            logger.error("MODEL_UNAVAILABLE: Prophet models are not loaded.")
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="MODEL_UNAVAILABLE"
            )

        # Validate expense history sufficiency (minimum 3 months required)
        if not history or len(history) < 3:
            logger.warning("INSUFFICIENT_HISTORY: Expense history contains fewer than 3 months (%d provided)",
                           len(history) if history else 0)
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="INSUFFICIENT_HISTORY"
            )

        future_periods = max(1, min(24, int(forecast_months or self.forecast_config.get("future_periods", 6))))
        
        # Determine starting date (first of next month)
        now = datetime.now()
        start_date = datetime(now.year, now.month, 1) + relativedelta(months=1)
        future_dates = [start_date + relativedelta(months=i) for i in range(future_periods)]
        future_df = pd.DataFrame({'ds': future_dates})

        try:
            fc_food = self.food_model.predict(future_df)
            fc_nf = self.nonfood_model.predict(future_df)
            fc_tot = self.total_model.predict(future_df)

            food_points: List[ForecastPoint] = []
            nonfood_points: List[ForecastPoint] = []
            total_points: List[ForecastPoint] = []

            for i, dt in enumerate(future_dates):
                date_str = dt.strftime('%Y-%m-%d')
                
                raw_f = float(fc_food.iloc[i]['yhat'])
                low_f = float(fc_food.iloc[i].get('yhat_lower', raw_f * 0.92))
                up_f = float(fc_food.iloc[i].get('yhat_upper', raw_f * 1.08))

                raw_nf = float(fc_nf.iloc[i]['yhat'])
                low_nf = float(fc_nf.iloc[i].get('yhat_lower', raw_nf * 0.90))
                up_nf = float(fc_nf.iloc[i].get('yhat_upper', raw_nf * 1.10))

                raw_tot = float(fc_tot.iloc[i]['yhat'])
                low_tot = float(fc_tot.iloc[i].get('yhat_lower', raw_tot * 0.91))
                up_tot = float(fc_tot.iloc[i].get('yhat_upper', raw_tot * 1.09))

                pred_f = round(max(0.0, raw_f), 2)
                pred_nf = round(max(0.0, raw_nf), 2)
                pred_tot = round(max(0.0, raw_tot), 2)

                food_points.append(ForecastPoint(date=date_str, predictedAmount=pred_f, lowerBound=round(max(0.0, low_f), 2), upperBound=round(max(pred_f, up_f), 2)))
                nonfood_points.append(ForecastPoint(date=date_str, predictedAmount=pred_nf, lowerBound=round(max(0.0, low_nf), 2), upperBound=round(max(pred_nf, up_nf), 2)))
                total_points.append(ForecastPoint(date=date_str, predictedAmount=pred_tot, lowerBound=round(max(0.0, low_tot), 2), upperBound=round(max(pred_tot, up_tot), 2)))

            logger.info("[ML_MODEL] Successfully generated %d monthly forecast periods using Prophet models", future_periods)
            return ForecastResponse(
                food=food_points,
                nonFood=nonfood_points,
                total=total_points,
                forecastMonths=future_periods,
                inference_source="ML_MODEL"
            )
        except Exception as pe:
            logger.error("Prophet prediction failed: %s", pe, exc_info=True)
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="MODEL_UNAVAILABLE"
            )

