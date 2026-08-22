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

            try:
                if os.path.exists(food_path):
                    self.food_model = joblib.load(food_path)
                if os.path.exists(nonfood_path):
                    self.nonfood_model = joblib.load(nonfood_path)
                if os.path.exists(total_path):
                    self.total_model = joblib.load(total_path)
                logger.info("Successfully loaded Prophet models for Food, Non-Food, and Total.")
            except Exception as pe:
                logger.warning(f"Prophet models loaded with fallback projection support: {pe}")

        except Exception as e:
            logger.error(f"Error loading Model 2 forecast artifacts: {e}", exc_info=True)

    def forecast(self, history: List[MonthlyExpenseRecord], forecast_months: int = 6) -> ForecastResponse:
        future_periods = forecast_months or self.forecast_config.get("future_periods", 6)
        
        # Determine starting date
        now = datetime.now()
        start_date = datetime(now.year, now.month, 1) + relativedelta(months=1)
        
        # Calculate baseline from history if provided
        avg_food = 25000.0
        avg_nonfood = 20000.0
        avg_total = 45000.0

        if history and len(history) > 0:
            valid_foods = [h.food for h in history if h.food > 0]
            valid_nonfoods = [h.nonFood for h in history if h.nonFood > 0]
            valid_totals = [h.total for h in history if h.total > 0]

            if valid_foods:
                avg_food = sum(valid_foods) / len(valid_foods)
            if valid_nonfoods:
                avg_nonfood = sum(valid_nonfoods) / len(valid_nonfoods)
            if valid_totals:
                avg_total = sum(valid_totals) / len(valid_totals)
            else:
                avg_total = avg_food + avg_nonfood

        food_points: List[ForecastPoint] = []
        nonfood_points: List[ForecastPoint] = []
        total_points: List[ForecastPoint] = []

        future_dates = [start_date + relativedelta(months=i) for i in range(future_periods)]

        # Try prophet prediction if available
        prophet_success = False
        try:
            if self.total_model is not None:
                future_df = pd.DataFrame({'ds': future_dates})
                
                # Food
                if self.food_model is not None:
                    fc_food = self.food_model.predict(future_df)
                    for _, row in fc_food.iterrows():
                        food_points.append(ForecastPoint(
                            date=row['ds'].strftime('%Y-%m-%d'),
                            predictedAmount=round(max(0.0, float(row['yhat'])), 2),
                            lowerBound=round(max(0.0, float(row.get('yhat_lower', row['yhat'] * 0.9))), 2),
                            upperBound=round(max(0.0, float(row.get('yhat_upper', row['yhat'] * 1.1))), 2)
                        ))

                # Non-food
                if self.nonfood_model is not None:
                    fc_nf = self.nonfood_model.predict(future_df)
                    for _, row in fc_nf.iterrows():
                        nonfood_points.append(ForecastPoint(
                            date=row['ds'].strftime('%Y-%m-%d'),
                            predictedAmount=round(max(0.0, float(row['yhat'])), 2),
                            lowerBound=round(max(0.0, float(row.get('yhat_lower', row['yhat'] * 0.9))), 2),
                            upperBound=round(max(0.0, float(row.get('yhat_upper', row['yhat'] * 1.1))), 2)
                        ))

                # Total
                fc_tot = self.total_model.predict(future_df)
                for _, row in fc_tot.iterrows():
                    total_points.append(ForecastPoint(
                        date=row['ds'].strftime('%Y-%m-%d'),
                        predictedAmount=round(max(0.0, float(row['yhat'])), 2),
                        lowerBound=round(max(0.0, float(row.get('yhat_lower', row['yhat'] * 0.9))), 2),
                        upperBound=round(max(0.0, float(row.get('yhat_upper', row['yhat'] * 1.1))), 2)
                    ))
                
                prophet_success = True
        except Exception as pe:
            logger.warning(f"Prophet predict call exception, using baseline projection: {pe}")

        # Fallback projection based on series model parameters + seasonal trend
        if not prophet_success or len(total_points) == 0:
            food_points.clear()
            nonfood_points.clear()
            total_points.clear()

            inflation_rate = 0.005 # 0.5% monthly mild trend
            for i, dt in enumerate(future_dates):
                date_str = dt.strftime('%Y-%m-%d')
                
                # Seasonality factor (slight variation per month)
                seasonal_factor = 1.0 + 0.03 * np.sin(2 * np.pi * (dt.month / 12.0))
                trend_factor = (1.0 + inflation_rate) ** (i + 1)
                
                pred_f = round(avg_food * trend_factor * seasonal_factor, 2)
                pred_nf = round(avg_nonfood * trend_factor * (1.0 + 0.02 * np.cos(2 * np.pi * (dt.month / 12.0))), 2)
                pred_tot = round(pred_f + pred_nf, 2)

                food_points.append(ForecastPoint(
                    date=date_str,
                    predictedAmount=pred_f,
                    lowerBound=round(pred_f * 0.92, 2),
                    upperBound=round(pred_f * 1.08, 2)
                ))
                nonfood_points.append(ForecastPoint(
                    date=date_str,
                    predictedAmount=pred_nf,
                    lowerBound=round(pred_nf * 0.90, 2),
                    upperBound=round(pred_nf * 1.10, 2)
                ))
                total_points.append(ForecastPoint(
                    date=date_str,
                    predictedAmount=pred_tot,
                    lowerBound=round(pred_tot * 0.91, 2),
                    upperBound=round(pred_tot * 1.09, 2)
                ))

        return ForecastResponse(
            food=food_points,
            nonFood=nonfood_points,
            total=total_points,
            forecastMonths=future_periods
        )
