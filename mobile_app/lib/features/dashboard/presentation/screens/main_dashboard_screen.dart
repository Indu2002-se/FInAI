import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/dashboard_model.dart';
import '../providers/dashboard_provider.dart';
import '../../../transaction_detection/presentation/providers/transaction_detection_provider.dart';
import '../../../transaction_detection/presentation/widgets/transaction_detection_banner.dart';

/// Main Financial Dashboard — all data from live backend + AI service.
class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your financial data…',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          error: (err, _) => _ErrorView(
            message: err.toString().replaceAll('Exception: ', ''),
            onRetry: () => ref.invalidate(dashboardFutureProvider),
          ),
          data: (data) => _DashboardBody(data: data),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard body
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardModel data;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _fmt(double v) {
    if (v >= 1000000) return 'Rs.${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'Rs.${(v / 1000).toStringAsFixed(0)}K';
    return 'Rs.${v.toStringAsFixed(0)}';
  }

  Color _riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high risk':
        return AppColors.error;
      case 'medium risk':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  Color _healthColor(double score) {
    if (score >= 75) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final healthScore = data.financialHealthScore;
    final budgetPct = data.monthlyBudgetAllocated > 0
        ? (data.monthlyBudgetSpent / data.monthlyBudgetAllocated).clamp(0.0, 1.0)
        : 0.0;
    final pendingCount = ref.watch(pendingCountProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              boxShadow: AppTheme.shadowMedium,
            ),
            padding: EdgeInsets.all(AppTheme.spacing20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child:
                      Icon(Icons.person, color: AppColors.darkTeal, size: 24),
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.white.withAlpha(230)),
                      ),
                      SizedBox(height: AppTheme.spacing4),
                      Text(
                        data.userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      tooltip: 'Auto-Detected Transactions',
                      onPressed: () => context.push(RouteNames.detectedTransactions),
                      icon: Icon(Icons.sms_outlined,
                          color: AppColors.white, size: 24),
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Transaction Detection Pending Banner ─────────────────────────────
          const SizedBox(height: 12),
          TransactionDetectionBanner(),

          // ── Financial Health Score ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing20),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Financial Health Score',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _riskColor(data.riskLevel).withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          data.riskLevel,
                          style: TextStyle(
                              color: _riskColor(data.riskLevel),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        healthScore.toStringAsFixed(0),
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: _healthColor(healthScore)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('/100',
                            style: TextStyle(
                                fontSize: 18, color: AppColors.mediumGrey)),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Risk Driver',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.mediumGrey)),
                          Text(
                            data.topRiskDriver,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing8),
                  // Inline progress bar
                  _LinearBar(
                      value: healthScore / 100.0,
                      color: _healthColor(healthScore)),
                ],
              ),
            ),
          ),

          // ── Key Metrics ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _MetricCard(
                            label: 'Income',
                            value: _fmt(data.totalIncome),
                            icon: Icons.arrow_downward,
                            color: AppColors.success)),
                    SizedBox(width: AppTheme.spacing12),
                    Expanded(
                        child: _MetricCard(
                            label: 'Expense',
                            value: _fmt(data.totalExpense),
                            icon: Icons.arrow_upward,
                            color: AppColors.error)),
                  ],
                ),
                SizedBox(height: AppTheme.spacing12),
                Row(
                  children: [
                    Expanded(
                        child: _MetricCard(
                            label: 'Net Savings',
                            value: _fmt(data.netSavings),
                            icon: Icons.savings,
                            color: data.netSavings >= 0
                                ? AppColors.success
                                : AppColors.error,
                            onTap: () =>
                                context.push(RouteNames.savingsGoals))),
                    SizedBox(width: AppTheme.spacing12),
                    Expanded(
                        child: _MetricCard(
                            label: 'Total Debt',
                            value: _fmt(data.totalDebt),
                            icon: Icons.credit_card,
                            color: data.totalDebt > 0
                                ? AppColors.warning
                                : AppColors.success)),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.spacing20),

          // ── Budget Progress ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Budget',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () =>
                            context.push(RouteNames.budgetDashboard),
                        child: const Text('Manage'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing8),
                  _LinearBar(
                    value: budgetPct,
                    color: budgetPct > 0.9
                        ? AppColors.error
                        : budgetPct > 0.7
                            ? AppColors.warning
                            : AppColors.success,
                  ),
                  SizedBox(height: AppTheme.spacing8),
                  _BudgetRow('Spent', _fmt(data.monthlyBudgetSpent)),
                  _BudgetRow('Allocated', _fmt(data.monthlyBudgetAllocated)),
                  _BudgetRow('Usage',
                      '${data.budgetUsagePercentage.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacing20),

          // ── Savings Goals & AI Strategy ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.savings_outlined,
                              color: AppColors.darkTeal, size: 20),
                          SizedBox(width: AppTheme.spacing8),
                          Text('Savings Goals & AI Plan',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(RouteNames.savingsGoals),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing4),
                  Text(
                    'Track savings targets with customized Gemini AI reports and month-by-month strategy roadmaps.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.mediumGrey, height: 1.3),
                  ),
                  SizedBox(height: AppTheme.spacing12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Create Goal', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.darkTeal,
                            side: BorderSide(color: AppColors.darkTeal),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () =>
                              context.push(RouteNames.createSavingsGoal),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('AI Savings Plan', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkTeal,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () =>
                              context.push(RouteNames.savingsGoals),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacing20),

          // ── AI Recommendation ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            child: GestureDetector(
              onTap: () => context.push(RouteNames.aiRecommendations),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkTeal, AppColors.tealLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: AppColors.white, size: 18),
                        SizedBox(width: AppTheme.spacing8),
                        Text('AI Insight',
                            style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            color: AppColors.white.withAlpha(200), size: 14),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      data.latestRecommendation,
                      style: TextStyle(
                          color: AppColors.white.withAlpha(230), fontSize: 13),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Text(
                      data.forecastSummary,
                      style: TextStyle(
                          color: AppColors.white.withAlpha(180), fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacing20),

          // ── Quick Actions ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
            child: Row(
              children: [
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Income',
                  onTap: () => context.push(RouteNames.addIncome),
                ),
                _QuickAction(
                  icon: Icons.remove_circle_outline,
                  label: 'Expense',
                  onTap: () => context.push(RouteNames.addExpense),
                ),
                _QuickAction(
                  icon: Icons.savings_outlined,
                  label: 'Savings',
                  onTap: () => context.push(RouteNames.savingsGoals),
                ),
                _QuickAction(
                  icon: Icons.insights,
                  label: 'Insights',
                  onTap: () => context.push(RouteNames.aiInsights),
                ),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  onTap: () => context.push(RouteNames.reports),
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.spacing20),

          // ── Recent Transactions ──────────────────────────────────────────────
          if (data.recentExpenses.isNotEmpty || data.recentIncomes.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Transactions',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => context.push(RouteNames.expenseList),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.spacing8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Column(
                      children: [
                        ...data.recentExpenses.take(3).map((e) => _TxItem(
                              title: e.category,
                              subtitle: e.description ?? e.paymentMethod ?? '',
                              amount: '-${_fmt(e.amount)}',
                              date: e.expenseDate,
                              isExpense: true,
                            )),
                        ...data.recentIncomes.take(2).map((i) => _TxItem(
                              title: i.source,
                              subtitle: i.description ?? i.category,
                              amount: '+${_fmt(i.amount)}',
                              date: i.incomeDate,
                              isExpense: false,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Alerts ───────────────────────────────────────────────────────────
          if (data.alerts.isNotEmpty) ...[
            SizedBox(height: AppTheme.spacing20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alerts',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: AppTheme.spacing8),
                  ...data.alerts.take(3).map((a) => _AlertTile(alert: a)),
                ],
              ),
            ),
          ],

          SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Simple animated horizontal progress bar
class _LinearBar extends StatelessWidget {
  const _LinearBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 700),
      builder: (_, v, __) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 10,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.mediumGrey)),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowCard,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mediumGrey,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey)),
        ],
      ),
    ));
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.shadowCard,
              ),
              child: Icon(icon, color: AppColors.darkTeal, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                style:
                    TextStyle(fontSize: 10, color: AppColors.darkGrey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TxItem extends StatelessWidget {
  const _TxItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isExpense,
  });
  final String title;
  final String subtitle;
  final String amount;
  final String date;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? Colors.red[700]! : Colors.green[700]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              color: color.withAlpha(20),
            ),
            child: Icon(
                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(date.length >= 10 ? date.substring(0, 10) : date,
                  style:
                      TextStyle(fontSize: 10, color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});
  final DashboardAlertItem alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.alertType == 'OVERSPEND'
        ? AppColors.error
        : alert.alertType == 'BUDGET_WARNING'
            ? AppColors.warning
            : AppColors.info;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 18),
          SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.darkGrey)),
                Text(alert.message,
                    style:
                        TextStyle(fontSize: 12, color: AppColors.mediumGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: AppColors.mediumGrey, size: 64),
          const SizedBox(height: 16),
          const Text('Unable to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(color: AppColors.mediumGrey, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
