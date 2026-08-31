import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/core/widgets/custom_button.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../data/models/child_models.dart';
import '../../data/repositories/child_repository.dart';
import '../providers/child_provider.dart';
import '../providers/child_selection_provider.dart';

/// Screen 35: Financial Quiz Screen
/// Shows a list of available quizzes, then steps through questions and submits.
class FinancialQuizScreen extends ConsumerStatefulWidget {
  const FinancialQuizScreen({super.key});

  @override
  ConsumerState<FinancialQuizScreen> createState() =>
      _FinancialQuizScreenState();
}

class _FinancialQuizScreenState extends ConsumerState<FinancialQuizScreen> {
  // ---- Quiz list state ----
  ChildQuizModel? _activeQuiz;

  // ---- In-quiz state ----
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionId → optionId
  bool _isSubmitting = false;

  void _startQuiz(ChildQuizModel quiz) {
    setState(() {
      _activeQuiz = quiz;
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    });
  }

  void _exitQuiz() {
    setState(() {
      _activeQuiz = null;
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
    });
  }

  Future<void> _submitQuiz() async {
    final quiz = _activeQuiz;
    if (quiz == null) return;
    setState(() => _isSubmitting = true);
    try {
      final selectedChild = ref.read(selectedChildProvider);
      final repo = ref.read(childRepositoryProvider);
      // Convert questionId→optionId map to the format backend expects
      final answers = _selectedAnswers.map(
        (questionId, optionId) => MapEntry(questionId.toString(), optionId),
      );
      final result = await repo.submitQuiz(
        quiz.id,
        answers.cast<String, int>(),
        childId: selectedChild?.id,
      );
      // Invalidate quizzes so isCompleted refreshes
      ref.invalidate(childQuizzesProvider);
      if (mounted) {
        context.push(RouteNames.quizResult, extra: result);
        _exitQuiz();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quiz: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_activeQuiz != null) {
      return _buildQuizPlayer(context, _activeQuiz!);
    }
    return _buildQuizList(context);
  }

  // ─────────────────────── QUIZ LIST ───────────────────────

  Widget _buildQuizList(BuildContext context) {
    final quizzesAsync = ref.watch(childQuizzesProvider);

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
          'FINANCIAL QUIZ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: quizzesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(
            message: error.toString(),
            onRetry: () => ref.invalidate(childQuizzesProvider),
          ),
          data: (quizzes) {
            if (quizzes.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No quizzes available yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for new financial literacy quizzes!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: quizzes.length,
              itemBuilder: (context, index) =>
                  _buildQuizCard(quizzes[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuizCard(ChildQuizModel quiz) {
    final isCompleted = quiz.isCompleted;
    final difficultyColor = _difficultyColor(quiz.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isCompleted ? Colors.green[50] : Colors.white,
      ),
      child: InkWell(
        onTap: quiz.totalQuestions == 0
            ? null
            : () {
                // Load full quiz detail before starting
                ref
                    .read(childQuizDetailProvider(quiz.id).future)
                    .then((fullQuiz) {
                  if (mounted) _startQuiz(fullQuiz);
                }).catchError((e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to load quiz: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (quiz.description != null && quiz.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  quiz.description!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _tag(quiz.difficulty, difficultyColor),
                  const SizedBox(width: 8),
                  _tag('${quiz.totalQuestions} Questions', Colors.blue),
                  const SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.amber[700], size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.rewardPoints} pts',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (isCompleted) ...[
                    const Spacer(),
                    Text(
                      'Score: ${quiz.lastScore}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────── QUIZ PLAYER ───────────────────────

  Widget _buildQuizPlayer(BuildContext context, ChildQuizModel quiz) {
    final questions = quiz.questions;
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No questions available for this quiz.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _exitQuiz,
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[_currentQuestionIndex];
    final isLast = _currentQuestionIndex == questions.length - 1;
    final selectedOptionId = _selectedAnswers[question.id];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitQuiz();
      },
      child: Scaffold(
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
              child:
                  const Icon(Icons.close, color: Colors.black87, size: 16),
            ),
            onPressed: _exitQuiz,
          ),
          title: Text(
            quiz.title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[200],
                  color: AppColors.darkTeal,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
                const SizedBox(height: 12),
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 32),
                ...question.options.map((option) {
                  final isSelected = selectedOptionId == option.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAnswers[question.id] = option.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue[700]!
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? Colors.blue[50] : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[700]!
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.white,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.optionText,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const Spacer(),
                CustomButton(
                  text: isLast ? 'Submit Quiz' : 'Next Question',
                  isLoading: _isSubmitting,
                  onPressed: selectedOptionId == null
                      ? null
                      : () {
                          if (isLast) {
                            _submitQuiz();
                          } else {
                            setState(() {
                              _currentQuestionIndex++;
                            });
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────── HELPERS ───────────────────────

  Widget _buildError({required String message, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load quizzes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
      case 'EASY':
        return Colors.green;
      case 'INTERMEDIATE':
      case 'MEDIUM':
        return Colors.orange;
      case 'ADVANCED':
      case 'HARD':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
