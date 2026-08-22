import os
import json
import logging
import urllib.request
import urllib.error
from typing import Dict, Any, List, Optional

logger = logging.getLogger("finai-ai.gemini-plan")

GEMINI_DEFAULT_API_KEY = "AQ.Ab8RN6LhCG0U8I_SFcltAROARC92y0QsiNgfkwA2_0YE06uSMA"

class GeminiSavingsPlanService:
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.environ.get("GEMINI_API_KEY", GEMINI_DEFAULT_API_KEY)

    def generate_plan(
        self,
        goal_title: str,
        target_amount: float,
        current_amount: float = 0.0,
        target_months: int = 6,
        monthly_income: float = 100000.0,
        monthly_expense: float = 60000.0,
        current_savings: float = 0.0,
        total_debt: float = 0.0,
        category_expenses: Optional[Dict[str, float]] = None
    ) -> Dict[str, Any]:
        """
        Generates an AI-driven personalized savings plan for a financial goal using Gemini API,
        with a deterministic algorithmic fallback.
        """
        net_target = max(0.0, target_amount - current_amount)
        months = max(1, target_months)
        monthly_required = round(net_target / months, 2)
        monthly_surplus = round(monthly_income - monthly_expense, 2)

        coverage_ratio = (monthly_surplus / monthly_required) if monthly_required > 0 else 1.0
        feasibility_score = min(100.0, max(10.0, round(coverage_ratio * 100.0, 1)))

        if coverage_ratio >= 1.2:
            status = "Highly Achievable"
            difficulty = "LOW"
        elif coverage_ratio >= 0.8:
            status = "Achievable with Minor Budget Adjustments"
            difficulty = "MEDIUM"
        elif coverage_ratio >= 0.4:
            status = "Challenging — Expense Reductions Required"
            difficulty = "HIGH"
        else:
            status = "High Difficulty — Timeline Extension or Income Boost Recommended"
            difficulty = "VERY_HIGH"

        # Generate milestone targets
        milestones = []
        for m in range(1, months + 1):
            accumulated = min(target_amount, current_amount + (monthly_required * m))
            pct = round((accumulated / target_amount) * 100.0, 1) if target_amount > 0 else 100.0
            milestones.append({
                "month": m,
                "targetAccumulated": round(accumulated, 2),
                "completionPercentage": pct
            })

        # Calculate category cuts if surplus is insufficient
        deficit = max(0.0, monthly_required - monthly_surplus)
        category_reductions = []
        if deficit > 0:
            category_reductions = [
                {
                    "category": "Entertainment & Leisure",
                    "suggestedCut": round(deficit * 0.40, 2),
                    "action": "Pause non-essential subscriptions and dine-out trips."
                },
                {
                    "category": "Food & Groceries",
                    "suggestedCut": round(deficit * 0.35, 2),
                    "action": "Switch to bulk weekly meal-prep to lower grocery bill."
                },
                {
                    "category": "Utilities & Discretionary",
                    "suggestedCut": round(deficit * 0.25, 2),
                    "action": "Optimize home electricity/data packages."
                }
            ]

        # Call Gemini API if API key exists
        gemini_report = self._call_gemini_api(
            goal_title=goal_title,
            target_amount=target_amount,
            current_amount=current_amount,
            target_months=months,
            monthly_required=monthly_required,
            monthly_income=monthly_income,
            monthly_expense=monthly_expense,
            monthly_surplus=monthly_surplus,
            status=status,
            category_expenses=category_expenses or {}
        )

        # Fallback structured markdown report if Gemini API is offline/not keyed
        if not gemini_report:
            gemini_report = self._build_fallback_report(
                goal_title=goal_title,
                target_amount=target_amount,
                current_amount=current_amount,
                target_months=months,
                monthly_required=monthly_required,
                monthly_income=monthly_income,
                monthly_expense=monthly_expense,
                monthly_surplus=monthly_surplus,
                status=status,
                difficulty=difficulty,
                category_reductions=category_reductions
            )

        return {
            "goalTitle": goal_title,
            "targetAmount": target_amount,
            "currentAmount": current_amount,
            "targetMonths": months,
            "monthlyRequiredSavings": monthly_required,
            "monthlySurplus": monthly_surplus,
            "feasibilityScore": feasibility_score,
            "feasibilityStatus": status,
            "difficultyLevel": difficulty,
            "categoryReductions": category_reductions,
            "milestones": milestones,
            "aiStrategyReport": gemini_report
        }

    def _call_gemini_api(
        self,
        goal_title: str,
        target_amount: float,
        current_amount: float,
        target_months: int,
        monthly_required: float,
        monthly_income: float,
        monthly_expense: float,
        monthly_surplus: float,
        status: str,
        category_expenses: Dict[str, float]
    ) -> Optional[str]:
        api_key = self.api_key or os.getenv("GEMINI_API_KEY", GEMINI_DEFAULT_API_KEY)
        if not api_key:
            return None

        prompt = f"""
You are FinAI's senior certified financial planner specializing in personal wealth optimization and savings strategy in Sri Lanka (LKR currency).

Analyze this user's specific savings goal and current financial standing to produce an empowering, clear, step-by-step savings roadmap:

### User Financial Profile:
- **Savings Goal**: {goal_title}
- **Target Amount**: LKR {target_amount:,.2f}
- **Already Saved**: LKR {current_amount:,.2f}
- **Target Timeline**: {target_months} months
- **Monthly Income**: LKR {monthly_income:,.2f}
- **Monthly Expenses**: LKR {monthly_expense:,.2f}
- **Current Monthly Surplus**: LKR {monthly_surplus:,.2f}
- **Required Monthly Savings**: LKR {monthly_required:,.2f}
- **Current Feasibility Assessment**: {status}

### Requirements for the Report:
1. **Executive Feasibility Summary**: Clear evaluation of whether the required savings fits the monthly surplus.
2. **Monthly Action Roadmap**: Clear breakdown of exact amounts to allocate each month.
3. **Category Expense Optimization**: Specific categories to trim in everyday Sri Lankan household budget.
4. **Emergency Buffer & Risk Protection**: How to avoid derailing this goal if unexpected expenses occur.
5. **Milestone Targets**: Month-by-month checkpoints to measure success.

Format your response in clean Markdown with friendly headers, bullet points, and practical tips. Keep the tone encouraging and actionable.
"""
        models_to_try = ["gemini-1.5-flash", "gemini-flash-latest", "gemini-2.0-flash"]
        for model_name in models_to_try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={api_key}"
            payload = {
                "contents": [
                    {
                        "parts": [{"text": prompt}]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.3,
                    "maxOutputTokens": 1024
                }
            }

            try:
                req = urllib.request.Request(
                    url,
                    data=json.dumps(payload).encode("utf-8"),
                    headers={
                        "Content-Type": "application/json",
                        "x-goog-api-key": api_key
                    }
                )
                with urllib.request.urlopen(req, timeout=12) as resp:
                    result = json.loads(resp.read().decode("utf-8"))
                    candidates = result.get("candidates", [])
                    if candidates:
                        text = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                        if text:
                            return text
            except Exception as e:
                logger.warning(f"Gemini API request ({model_name}) failed: {e}")
                continue
        return None

    def _build_fallback_report(
        self,
        goal_title: str,
        target_amount: float,
        current_amount: float,
        target_months: int,
        monthly_required: float,
        monthly_income: float,
        monthly_expense: float,
        monthly_surplus: float,
        status: str,
        difficulty: str,
        category_reductions: List[Dict[str, Any]]
    ) -> str:
        cuts_text = ""
        if category_reductions:
            cuts_text = "\n### ✂️ Recommended Expense Cuts:\n"
            for c in category_reductions:
                cuts_text += f"- **{c['category']}**: Reduce by ~Rs. {c['suggestedCut']:,.0f}/mo ({c['action']})\n"
        else:
            cuts_text = "\n### 💡 Budget Optimization:\n- Your current monthly surplus (Rs. " + f"{monthly_surplus:,.0f}" + ") comfortably covers your target savings of Rs. " + f"{monthly_required:,.0f}" + "/month.\n"

        return f"""## 🎯 AI Savings Roadmap: {goal_title}

### 📊 Feasibility Summary
- **Target Goal**: Rs. {target_amount:,.0f} over {target_months} months
- **Required Monthly Savings**: **Rs. {monthly_required:,.0f} / month**
- **Current Monthly Surplus**: Rs. {monthly_surplus:,.0f} / month
- **Feasibility Status**: **{status}**

---
{cuts_text}
### 🗓️ Key Milestones:
- **Month 1 Checkpoint**: Accumulate Rs. {min(target_amount, current_amount + monthly_required):,.0f}
- **Halfway Mark ({max(1, target_months // 2)} Months)**: Reach Rs. {min(target_amount, current_amount + (monthly_required * max(1, target_months // 2))):,.0f}
- **Goal Completion ({target_months} Months)**: Full Target of Rs. {target_amount:,.0f} reached!

### 🛡️ Smart Saving Tactics:
1. **Automate on Payday**: Transfer your Rs. {monthly_required:,.0f} savings immediately on salary day before spending.
2. **High-Yield Savings**: Keep this fund in a high-yield account or fixed deposit to earn interest compounding.
3. **Emergency Safeguard**: Ensure your primary emergency fund remains untouched while building this goal.
"""
