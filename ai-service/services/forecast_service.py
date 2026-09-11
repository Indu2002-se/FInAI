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
    """
    Model 2: Personalized Expense Forecaster using Facebook Prophet (Option B).
    
    Inference Design:
    - Fits piecewise linear Prophet time-series models directly on the user's own empirical
      expense history (Food, Non-Food, Total).
    - Calibrated hyperparameters (changepoint_prior_scale) are loaded from model2_forecast_config.joblib.
    - Reference artifacts (model2_food_prophet.joblib, etc.) establish baseline integrity.
    - Requires at least 3 distinct calendar months of history for a usable trend estimate.
    - Zero synthetic or hardcoded financial baselines (no 5300, no 82000, no arbitrary multipliers).
    """
    MIN_HISTORY_MONTHS = 3

    def __init__(self, models_dir: str):
        self.models_dir = models_dir
        self.food_model = None
        self.nonfood_model = None
        self.total_model = None
        self.forecast_config = None
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
                self.forecast_config = None
                self.food_model = None
                self.nonfood_model = None
                self.total_model = None
                return

            self.forecast_config = joblib.load(config_path)
            self.food_model = joblib.load(food_path)
            self.nonfood_model = joblib.load(nonfood_path)
            self.total_model = joblib.load(total_path)
            logger.info("Loaded Model 2 configuration and baseline models successfully.")

        except Exception as e:
            logger.error(f"MODEL_UNAVAILABLE: Error loading Model 2 forecast artifacts: {e}", exc_info=True)
            self.forecast_config = None
            self.food_model = None
            self.nonfood_model = None
            self.total_model = None

    def forecast(self, history: List[MonthlyExpenseRecord], forecast_months: int = 6) -> ForecastResponse:
        # Check if forecast configuration and models are available
        if self.forecast_config is None or self.food_model is None or self.nonfood_model is None or self.total_model is None:
            logger.error("MODEL_UNAVAILABLE: Forecast configuration or models are not loaded.")
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="MODEL_UNAVAILABLE"
            )

        # Validate expense history sufficiency (minimum 3 distinct calendar months)
        if not history or len(history) < self.MIN_HISTORY_MONTHS:
            logger.warning("INSUFFICIENT_HISTORY: Expense history contains fewer than %d months (%d provided)",
                           self.MIN_HISTORY_MONTHS, len(history) if history else 0)
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="INSUFFICIENT_HISTORY"
            )

        # Validate entries and convert to timestamps
        parsed_records = []
        for r in history:
            try:
                raw_date = r.date.strip()
                if len(raw_date) == 7:
                    dt = datetime.strptime(raw_date, "%Y-%m")
                else:
                    dt = datetime.strptime(raw_date[:10], "%Y-%m-%d")
                dt = datetime(dt.year, dt.month, 1)

                food_val = float(r.food if r.food is not None else 0.0)
                nonfood_val = float(r.nonFood if r.nonFood is not None else 0.0)
                total_val = float(r.total if r.total is not None else (food_val + nonfood_val))

                if total_val <= 0.0 and (food_val > 0 or nonfood_val > 0):
                    total_val = food_val + nonfood_val

                if total_val < 0.0 or food_val < 0.0 or nonfood_val < 0.0:
                    logger.warning("Negative expenditure detected in history record: %s", r)
                    continue

                parsed_records.append({
                    "ds": dt,
                    "food": max(0.0, food_val),
                    "nonFood": max(0.0, nonfood_val),
                    "total": max(0.0, total_val)
                })
            except Exception as e:
                logger.warning("Failed to parse history record %s: %s", r, e)
                continue

        # Sort chronologically by date
        parsed_records.sort(key=lambda x: x["ds"])

        # Deduplicate by distinct calendar month
        month_map: Dict[str, Dict[str, Any]] = {}
        for rec in parsed_records:
            k = rec["ds"].strftime("%Y-%m")
            month_map[k] = rec
        deduped = sorted(month_map.values(), key=lambda x: x["ds"])

        if len(deduped) < self.MIN_HISTORY_MONTHS:
            logger.warning("INSUFFICIENT_HISTORY: Distinct historical months after deduplication is %d (< %d)",
                           len(deduped), self.MIN_HISTORY_MONTHS)
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="INSUFFICIENT_HISTORY"
            )

        # Build Prophet time series dataframes
        df_hist = pd.DataFrame(deduped)
        future_periods = max(1, min(24, int(forecast_months or self.forecast_config.get("future_periods", 6))))

        latest_dt = deduped[-1]["ds"]
        start_date = datetime(latest_dt.year, latest_dt.month, 1) + relativedelta(months=1)
        future_dates = [start_date + relativedelta(months=i) for i in range(future_periods)]
        future_df = pd.DataFrame({"ds": future_dates})

        try:
            from prophet import Prophet

            food_prior = float(self.forecast_config.get("food_changepoint_prior_scale", 0.05))
            nf_prior = float(self.forecast_config.get("nonfood_changepoint_prior_scale", 0.2))
            tot_prior = float(self.forecast_config.get("total_changepoint_prior_scale", 0.2))

            # Fit Food model on real user data
            m_food = Prophet(growth="linear", yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False, changepoint_prior_scale=food_prior)
            m_food.fit(pd.DataFrame({"ds": df_hist["ds"], "y": df_hist["food"]}))
            fc_food = m_food.predict(future_df)

            # Fit Non-Food model on real user data
            m_nf = Prophet(growth="linear", yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False, changepoint_prior_scale=nf_prior)
            m_nf.fit(pd.DataFrame({"ds": df_hist["ds"], "y": df_hist["nonFood"]}))
            fc_nf = m_nf.predict(future_df)

            # Fit Total model on real user data
            m_tot = Prophet(growth="linear", yearly_seasonality=False, weekly_seasonality=False, daily_seasonality=False, changepoint_prior_scale=tot_prior)
            m_tot.fit(pd.DataFrame({"ds": df_hist["ds"], "y": df_hist["total"]}))
            fc_tot = m_tot.predict(future_df)

            food_points: List[ForecastPoint] = []
            nonfood_points: List[ForecastPoint] = []
            total_points: List[ForecastPoint] = []

            for i, dt in enumerate(future_dates):
                date_str = dt.strftime("%Y-%m-%d")

                raw_f = float(fc_food.iloc[i]["yhat"])
                low_f = float(fc_food.iloc[i].get("yhat_lower", raw_f * 0.92))
                up_f = float(fc_food.iloc[i].get("yhat_upper", raw_f * 1.08))

                raw_nf = float(fc_nf.iloc[i]["yhat"])
                low_nf = float(fc_nf.iloc[i].get("yhat_lower", raw_nf * 0.90))
                up_nf = float(fc_nf.iloc[i].get("yhat_upper", raw_nf * 1.10))

                raw_tot = float(fc_tot.iloc[i]["yhat"])
                low_tot = float(fc_tot.iloc[i].get("yhat_lower", raw_tot * 0.91))
                up_tot = float(fc_tot.iloc[i].get("yhat_upper", raw_tot * 1.09))

                pred_f = round(max(0.0, raw_f), 2)
                pred_nf = round(max(0.0, raw_nf), 2)
                pred_tot = round(max(0.0, raw_tot), 2)

                food_points.append(ForecastPoint(date=date_str, predictedAmount=pred_f, lowerBound=round(max(0.0, low_f), 2), upperBound=round(max(pred_f, up_f), 2)))
                nonfood_points.append(ForecastPoint(date=date_str, predictedAmount=pred_nf, lowerBound=round(max(0.0, low_nf), 2), upperBound=round(max(pred_nf, up_nf), 2)))
                total_points.append(ForecastPoint(date=date_str, predictedAmount=pred_tot, lowerBound=round(max(0.0, low_tot), 2), upperBound=round(max(pred_tot, up_tot), 2)))

            logger.info("[ML_MODEL] Successfully generated %d personalized monthly forecast periods using Prophet on user history", future_periods)
            return ForecastResponse(
                food=food_points,
                nonFood=nonfood_points,
                total=total_points,
                forecastMonths=future_periods,
                inference_source="ML_MODEL"
            )

        except Exception as pe:
            logger.error("Prophet user-level forecasting failed: %s", pe, exc_info=True)
            return ForecastResponse(
                food=[],
                nonFood=[],
                total=[],
                forecastMonths=0,
                inference_source="MODEL_UNAVAILABLE"
            )

