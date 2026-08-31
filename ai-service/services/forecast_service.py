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
            if os.path.exists(config_path):
                self.forecast_config = joblib.load(config_path)

            food_path = os.path.join(self.models_dir, "model2_food_prophet.joblib")
            nonfood_path = os.path.join(self.models_dir, "model2_nonfood_prophet.joblib")
            total_path = os.path.join(self.models_dir, "model2_total_prophet.joblib")

            if os.path.exists(food_path):
                self.food_model = joblib.load(food_path)
            if os.path.exists(nonfood_path):
                self.nonfood_model = joblib.load(nonfood_path)
            if os.path.exists(total_path):
                self.total_model = joblib.load(total_path)

            models_loaded = sum(1 for m in [self.food_model, self.nonfood_model, self.total_model] if m is not None)
            logger.info("Loaded %d/3 Model 2 Prophet models (Food, Non-Food, Total).", models_loaded)

        except Exception as e:
            logger.error(f"Error loading Model 2 forecast artifacts: {e}", exc_info=True)

    def forecast(self, history: List[MonthlyExpenseRecord], forecast_months: int = 6) -> ForecastResponse:
        future_periods = max(1, min(24, int(forecast_months or self.forecast_config.get("future_periods", 6))))
        
        # Determine starting date (first of next month)
        now = datetime.now()
        start_date = datetime(now.year, now.month, 1) + relativedelta(months=1)
        future_dates = [start_date + relativedelta(months=i) for i in range(future_periods)]

        # 1. Sort and process input history chronologically
        sorted_history: List[MonthlyExpenseRecord] = []
        if history:
            try:
                sorted_history = sorted(history, key=lambda h: str(h.date))
            except Exception:
                sorted_history = list(history)

        # 2. Calculate baseline expenditure levels from user history (or defaults)
        avg_food = 25000.0
        avg_nonfood = 20000.0
        avg_total = 45000.0
        has_user_history = False

        if sorted_history:
            valid_foods = [h.food for h in sorted_history if h.food > 0]
            valid_nonfoods = [h.nonFood for h in sorted_history if h.nonFood > 0]
            valid_totals = [h.total for h in sorted_history if h.total > 0]

            if valid_foods:
                avg_food = float(np.mean(valid_foods))
                has_user_history = True
            if valid_nonfoods:
                avg_nonfood = float(np.mean(valid_nonfoods))
                has_user_history = True
            if valid_totals:
                avg_total = float(np.mean(valid_totals))
                has_user_history = True
            else:
                avg_total = avg_food + avg_nonfood

        food_points: List[ForecastPoint] = []
        nonfood_points: List[ForecastPoint] = []
        total_points: List[ForecastPoint] = []

        # 3. Attempt Prophet ML Prediction
        prophet_success = False
        if self.total_model is not None and self.food_model is not None and self.nonfood_model is not None:
            try:
                future_df = pd.DataFrame({'ds': future_dates})
                fc_food = self.food_model.predict(future_df)
                fc_nf = self.nonfood_model.predict(future_df)
                fc_tot = self.total_model.predict(future_df)

                # Reference training baselines for Prophet models (~5300 food, ~82000 nonfood, ~87000 total)
                train_base_food = 5300.0
                train_base_nf = 82000.0
                train_base_tot = 87300.0

                for i, dt in enumerate(future_dates):
                    date_str = dt.strftime('%Y-%m-%d')
                    
                    row_f = fc_food.iloc[i]
                    row_nf = fc_nf.iloc[i]
                    row_tot = fc_tot.iloc[i]

                    raw_f = float(row_f['yhat'])
                    raw_nf = float(row_nf['yhat'])
                    raw_tot = float(row_tot['yhat'])

                    # If user history exists, apply Prophet seasonal dynamics to user's baseline
                    if has_user_history:
                        # Extract seasonal factor relative to base
                        season_f = (raw_f / train_base_food) if (raw_f > 0 and train_base_food > 0) else 1.0
                        season_nf = (raw_nf / train_base_nf) if (raw_nf > 0 and train_base_nf > 0) else 1.0
                        
                        # Guard against negative / divergent seasonal multipliers
                        season_f = float(np.clip(season_f, 0.7, 1.4))
                        season_nf = float(np.clip(season_nf, 0.7, 1.4))

                        pred_f = round(max(0.0, avg_food * season_f), 2)
                        pred_nf = round(max(0.0, avg_nonfood * season_nf), 2)
                        pred_tot = round(pred_f + pred_nf, 2)
                    else:
                        # Direct model output with non-negativity constraint
                        pred_f = round(max(0.0, raw_f if raw_f > 0 else avg_food), 2)
                        pred_nf = round(max(0.0, raw_nf if raw_nf > 0 else avg_nonfood), 2)
                        pred_tot = round(max(0.0, raw_tot if raw_tot > 0 else pred_f + pred_nf), 2)

                    # Bounds
                    lower_f = round(max(0.0, pred_f * 0.92), 2)
                    upper_f = round(max(pred_f, pred_f * 1.08), 2)

                    lower_nf = round(max(0.0, pred_nf * 0.90), 2)
                    upper_nf = round(max(pred_nf, pred_nf * 1.10), 2)

                    lower_tot = round(max(0.0, pred_tot * 0.91), 2)
                    upper_tot = round(max(pred_tot, pred_tot * 1.09), 2)

                    food_points.append(ForecastPoint(date=date_str, predictedAmount=pred_f, lowerBound=lower_f, upperBound=upper_f))
                    nonfood_points.append(ForecastPoint(date=date_str, predictedAmount=pred_nf, lowerBound=lower_nf, upperBound=upper_nf))
                    total_points.append(ForecastPoint(date=date_str, predictedAmount=pred_tot, lowerBound=lower_tot, upperBound=upper_tot))

                prophet_success = True
                logger.info("[PROPHET_MODEL] Successfully generated %d monthly forecast periods using Prophet models", future_periods)
            except Exception as pe:
                logger.warning("Prophet model prediction failed (%s). Falling back to seasonal trend model.", pe)

        # 4. Fallback Projection (Triggered only when Prophet is unavailable or failed)
        if not prophet_success or len(total_points) == 0:
            food_points.clear()
            nonfood_points.clear()
            total_points.clear()

            inflation_rate = 0.005 # 0.5% monthly mild trend
            for i, dt in enumerate(future_dates):
                date_str = dt.strftime('%Y-%m-%d')
                
                seasonal_factor_f = 1.0 + 0.03 * np.sin(2 * np.pi * (dt.month / 12.0))
                seasonal_factor_nf = 1.0 + 0.02 * np.cos(2 * np.pi * (dt.month / 12.0))
                trend_factor = (1.0 + inflation_rate) ** (i + 1)
                
                pred_f = round(max(0.0, avg_food * trend_factor * seasonal_factor_f), 2)
                pred_nf = round(max(0.0, avg_nonfood * trend_factor * seasonal_factor_nf), 2)
                pred_tot = round(pred_f + pred_nf, 2)

                food_points.append(ForecastPoint(date=date_str, predictedAmount=pred_f, lowerBound=round(pred_f * 0.92, 2), upperBound=round(pred_f * 1.08, 2)))
                nonfood_points.append(ForecastPoint(date=date_str, predictedAmount=pred_nf, lowerBound=round(pred_nf * 0.90, 2), upperBound=round(pred_nf * 1.10, 2)))
                total_points.append(ForecastPoint(date=date_str, predictedAmount=pred_tot, lowerBound=round(pred_tot * 0.91, 2), upperBound=round(pred_tot * 1.09, 2)))

            logger.info("[FALLBACK] Generated %d forecast periods using seasonal trend model", future_periods)

        return ForecastResponse(
            food=food_points,
            nonFood=nonfood_points,
            total=total_points,
            forecastMonths=future_periods
        )

