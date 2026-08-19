import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/stat_row.dart';
import '../../../../app/core/widgets/progress_bar.dart';
import '../../../../app/core/widgets/transaction_list_item.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';

/// Screen 11: Main Financial Dashboard
/// Wireframe: Greeting + Stats + Budget Progress + Health Score + Quick Actions + Chart + Transactions + AI Recommendation
class MainDashboardScreen extends ConsumerWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting section with gradient header
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacing20),
                  child: Row(
                    children: [
                      // Avatar with gradient border
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.tealLight,
                              AppColors.white.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.darkTeal,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: AppTheme.spacing12),
                      // Greeting text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            Text(
                              'John Silva',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification bell with badge
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.darkTeal,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacing20),

              // Stats row with enhanced design
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: StatRow(
                  items: [
                    StatItem(
                      label: 'Balance',
                      value: 'Rs.85k',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.darkTeal,
                    ),
                    StatItem(
                      label: 'Income',
                      value: 'Rs.150k',
                      icon: Icons.trending_up,
                      color: AppColors.success,
                      trend: '+12%',
                      trendIsPositive: true,
                    ),
                    StatItem(
                      label: 'Expenses',
                      value: 'Rs.65k',
                      icon: Icons.trending_down,
                      color: AppColors.error,
                      trend: '+8%',
                      trendIsPositive: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing24),

              // Budget Progress with better design
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: Container(
                  padding: EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowSoft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Budget Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacing12,
                              vertical: AppTheme.spacing4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              '65% Used',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing12),
                      ProgressBarWidget(
                        progress: 0.65,
                        height: 12,
                        color: AppColors.warning,
                        showPercentage: false,
                      ),
                      SizedBox(height: AppTheme.spacing8),
                      Text(
                        'Rs.65,000 of Rs.100,000',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacing20),

              // Financial Health Score Card with gradient
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: InfoCard(
                  title: 'Financial Health Score',
                  subtitle: 'Your financial wellness rating',
                  variant: CardVariant.gradient,
                  leading: Container(
                    padding: EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      gradient: AppColors.successGradient,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '78',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Good',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.push(RouteNames.financialHealth);
                  },
                ),
              ),

              SizedBox(height: AppTheme.spacing24),

              // Quick Actions with modern design
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernQuickAction(
                            context: context,
                            icon: Icons.add_circle,
                            label: 'Add Income',
                            color: AppColors.success,
                            onTap: () => context.push(RouteNames.addIncome),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: _buildModernQuickAction(
                            context: context,
                            icon: Icons.remove_circle,
                            label: 'Add Expense',
                            color: AppColors.error,
                            onTap: () => context.push(RouteNames.addExpense),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          child: _buildModernQuickAction(
                            context: context,
                            icon: Icons.pie_chart,
                            label: 'Budget',
                            color: AppColors.purple,
                            onTap: () =>
                                context.push(RouteNames.budgetDashboard),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing24),

              // Expense Summary Chart
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: Container(
                  padding: EdgeInsets.all(AppTheme.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowCard,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expense Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(RouteNames.reports),
                            child: Text(
                              'View All',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.darkTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppTheme.spacing16),
                      // Simple bar chart placeholder with gradient
                      SizedBox(
                        height: 120,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildGradientBar(40, 'Mon'),
                            _buildGradientBar(70, 'Tue'),
                            _buildGradientBar(55, 'Wed'),
                            _buildGradientBar(90, 'Thu'),
                            _buildGradientBar(35, 'Fri'),
                            _buildGradientBar(60, 'Sat'),
                            _buildGradientBar(80, 'Sun'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacing24),

              // Recent Transactions with header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.expenseList),
                      child: Text(
                        'See All',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.darkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing12),

              Container(
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.shadowSoft,
                ),
                child: Column(
                  children: const [
                    TransactionListItem(
                      title: 'Grocery Store',
                      subtitle: 'Food • Today',
                      value: '-Rs.2,500',
                      icon: Icons.shopping_cart,
                      isIncome: false,
                    ),
                    TransactionListItem(
                      title: 'Salary',
                      subtitle: 'Income • Yesterday',
                      value: '+Rs.150,000',
                      icon: Icons.account_balance_wallet,
                      isIncome: true,
                    ),
                    TransactionListItem(
                      title: 'Electricity Bill',
                      subtitle: 'Utilities • 2 days ago',
                      value: '-Rs.4,200',
                      icon: Icons.flash_on,
                      isIncome: false,
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing20),

              // AI Recommendation with modern card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
                child: InfoCard(
                  title: 'AI Recommendation',
                  subtitle: 'Personalized financial advice',
                  variant: CardVariant.elevated,
                  backgroundColor: AppColors.infoLight,
                  leading: Container(
                    padding: EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  lines: const [
                    'Reduce dining expenses by 10% to reach your savings goal faster. You\'ve spent Rs.15,000 on dining this month.',
                  ],
                  onTap: () => context.push(RouteNames.aiRecommendations),
                ),
              ),

              SizedBox(height: AppTheme.spacing90), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildModernQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.spacing16,
          horizontal: AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.shadowSoft,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBar(double height, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: height,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.darkTeal,
                  AppColors.tealLight,
                ],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusSmall),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkTeal.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: AppTheme.spacing8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.mediumGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
