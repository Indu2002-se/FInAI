import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_models.dart';
import '../providers/child_provider.dart';

/// Screen 38: Rewards Screen
/// Displays the child's total earned points and their list of unlocked/available
/// rewards from the live backend via [childRewardsProvider] and
/// [childDashboardProvider].
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(childRewardsProvider);
    final dashboardAsync = ref.watch(childDashboardProvider);

    // Resolve total points from dashboard; fall back to 0 while loading
    final totalPoints = dashboardAsync.maybeWhen(
      data: (d) => d.totalPoints,
      orElse: () => 0,
    );

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MY REWARDS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: rewardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(
            context: context,
            message: error.toString(),
            onRetry: () {
              ref.invalidate(childRewardsProvider);
              ref.invalidate(childDashboardProvider);
            },
          ),
          data: (rewards) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Points banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.amber[700]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.amber[50],
                ),
                child: Column(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 56),
                    const SizedBox(height: 12),
                    Text(
                      '$totalPoints Points',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Earned',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              if (rewards.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No rewards yet!',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Complete quizzes and savings goals to earn badges.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'EARNED REWARDS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                ...rewards.map((reward) => _buildRewardItem(reward, totalPoints)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(ChildRewardModel reward, int totalPoints) {
    final isUnlocked = reward.unlockedAt != null;
    final iconData = _iconForType(reward.rewardType);
    final color = _colorForType(reward.rewardType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
            color: isUnlocked ? Colors.amber[200]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: isUnlocked ? Colors.amber[50] : Colors.grey[50],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUnlocked ? iconData : Icons.lock_outline,
              color: isUnlocked ? color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (reward.description != null &&
                    reward.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reward.description!,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[700], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.pointsAwarded} pts',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Earned',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load rewards',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String rewardType) {
    switch (rewardType.toUpperCase()) {
      case 'BADGE':
        return Icons.military_tech;
      case 'POINTS':
        return Icons.star;
      case 'QUIZ':
        return Icons.quiz;
      case 'SAVINGS':
        return Icons.savings;
      default:
        return Icons.emoji_events;
    }
  }

  Color _colorForType(String rewardType) {
    switch (rewardType.toUpperCase()) {
      case 'BADGE':
        return Colors.amber;
      case 'POINTS':
        return Colors.orange;
      case 'QUIZ':
        return Colors.blue;
      case 'SAVINGS':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}
