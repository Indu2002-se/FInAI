import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_names.dart';
import '../../theme/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppTheme.spacing12,
              horizontal: AppTheme.spacing12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavPill(
                  context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  route: RouteNames.dashboard,
                  theme: theme,
                ),
                _buildNavPill(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Transaction',
                  index: 1,
                  route: RouteNames.expenseList,
                  theme: theme,
                ),
                _buildNavPill(
                  context,
                  icon: Icons.pie_chart_rounded,
                  label: 'Budget',
                  index: 2,
                  route: RouteNames.budgetDashboard,
                  theme: theme,
                ),
                _buildNavPill(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Insights',
                  index: 3,
                  route: RouteNames.aiInsights,
                  theme: theme,
                ),
                _buildNavPill(
                  context,
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  route: RouteNames.profile,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
    required ThemeData theme,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isActive) {
            context.go(route);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: AppColors.white,
            ),
            SizedBox(height: AppTheme.spacing4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
