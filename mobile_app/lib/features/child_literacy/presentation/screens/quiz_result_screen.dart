import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/router/route_names.dart';
import '../../data/models/child_models.dart';

/// Screen 36: Quiz Result Screen
/// Receives a [ChildQuizResultModel] via [GoRouterState.extra] and
/// displays the real score, points earned, and per-question breakdown.
class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Receive live result from quiz submission
    final result = GoRouterState.of(context).extra as ChildQuizResultModel?;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('QUIZ RESULTS'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No result data available.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final passed = result.passed;
    final resultColor = passed ? Colors.green[700]! : Colors.orange[700]!;
    final resultIcon =
        passed ? Icons.emoji_events : Icons.sentiment_satisfied_alt;
    final resultLabel = passed ? 'Great Job!' : 'Keep Practicing!';

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
          'QUIZ RESULTS',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Result banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: resultColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: resultColor.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    Icon(resultIcon, color: resultColor, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      resultLabel,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.quizTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${result.score} / ${result.totalQuestions}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: resultColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answers  •  ${result.scorePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Points earned ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '+${result.earnedPoints} Points',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      passed
                          ? 'You earned ${result.earnedPoints} reward points!'
                          : 'Keep practicing to earn more points!',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    if (result.earnedBadge != null &&
                        result.earnedBadge!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.military_tech,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Badge Earned: ${result.earnedBadge}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Action buttons ──
              CustomButton(
                text: 'Try Another Quiz',
                onPressed: () {
                  // Pop back to quiz list
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Back to Dashboard',
                variant: ButtonVariant.outline,
                onPressed: () => context.go(RouteNames.childDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
