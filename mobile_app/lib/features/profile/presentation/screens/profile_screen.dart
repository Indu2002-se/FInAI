import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/core/widgets/info_card.dart';
import '../../../../app/core/widgets/bottom_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_notifier.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

/// Screen 10: Profile Screen — Live Data Connected
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return authState.maybeWhen(
      authenticated: (user) => _buildProfileContent(context, ref, user),
      orElse: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not logged in'),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  context.go(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, dynamic user) {
    final dashboardAsync = ref.watch(dashboardFutureProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black87, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 16),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.dashboard);
            }
          },
        ),
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info card with real name and email
              InfoCard(
                title: (user?.firstName != null && user?.lastName != null)
                    ? '${user.firstName} ${user.lastName}'
                    : 'Account Profile',
                lines: [
                  user?.email ?? 'user@finai.com',
                  'FinAI Member',
                ],
              ),
              const SizedBox(height: 24),
              // Live Financial Summary
              const Text(
                'FINANCIAL PROFILE SUMMARY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              dashboardAsync.when(
                loading: () => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text('Unable to load financial summary: $err'),
                ),
                data: (data) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: AppTheme.shadowCard,
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Monthly Income',
                          'Rs. ${data.totalIncome.toStringAsFixed(0)}',
                          AppColors.success,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Monthly Expenses',
                          'Rs. ${data.totalExpense.toStringAsFixed(0)}',
                          AppColors.error,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Net Monthly Savings',
                          'Rs. ${data.netSavings.toStringAsFixed(0)}',
                          data.netSavings >= 0 ? AppColors.success : AppColors.error,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Active Debt',
                          'Rs. ${data.totalDebt.toStringAsFixed(0)}',
                          data.totalDebt > 0 ? AppColors.warning : AppColors.success,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Financial Health Score',
                          '${data.financialHealthScore.toStringAsFixed(0)} / 100 (${data.riskLevel})',
                          AppColors.darkTeal,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Savings Goals button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tealExtraLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.savings_outlined, color: AppColors.darkTeal),
                  ),
                  title: const Text(
                    'Savings Goals & AI Plans',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Track targets & Gemini AI strategy roadmaps',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => context.push(RouteNames.savingsGoals),
                ),
              ),
              const SizedBox(height: 12),
              // Auto-Detected Transactions button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.shadowCard,
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.tealExtraLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sms_outlined, color: AppColors.darkTeal),
                  ),
                  title: const Text(
                    'Auto-Detected Transactions',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Bank SMS & notification listeners & settings',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => context.push(RouteNames.detectedTransactions),
                ),
              ),
              const SizedBox(height: 24),
              // Logout button
              CustomButton(
                text: 'Logout',
                variant: ButtonVariant.outline,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RouteNames.login);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 4),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
