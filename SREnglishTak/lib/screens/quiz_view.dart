import 'package:flutter/material.dart';

import '../models/quiz.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_scale_button.dart';
import 'quiz_results.dart';
import '../widgets/premium_background.dart';

class QuizView extends StatefulWidget {
  final String? bookId;
  final String? quizId;
  const QuizView({super.key, this.bookId, this.quizId});

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  late Future<List<Quiz>> _quizzesFuture;
  int _currentQuizIndex = 0;
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  int _score = 0;
  bool _isSubmitting = false;
  bool _hasCheckedAnswer = false;
  String _filterType = 'general';

  @override
  void initState() {
    super.initState();
    _quizzesFuture = ApiService.getQuizzes();
  }

  Future<void> _handleBottomButtonTap(List<Quiz> quizzes) async {
    final currentQuiz = quizzes[_currentQuizIndex];
    final questions = currentQuiz.questions;
    if (_selectedOption == null || questions == null || questions.isEmpty) return;

    final currentQuestion = questions[_currentQuestionIndex];

    if (!_hasCheckedAnswer) {
      setState(() {
        _hasCheckedAnswer = true;
        if (_selectedOption == currentQuestion.correctOptionIndex) {
          _score++;
        }
      });
      return;
    }

    // Move to next question or submit
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _hasCheckedAnswer = false;
      });
    } else if (_currentQuizIndex < quizzes.length - 1) {
      setState(() {
        _currentQuizIndex++;
        _currentQuestionIndex = 0;
        _selectedOption = null;
        _hasCheckedAnswer = false;
      });
    } else {
      setState(() => _isSubmitting = true);
      try {
        await ApiService.submitQuizResult(
          currentQuiz.id,
          _score,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizResults(score: _score, total: quizzes.fold(0, (sum, q) => sum + (q.questions?.length ?? 0))),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error submitting quiz: $e')));
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: FutureBuilder<List<Quiz>>(
            future: _quizzesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No quizzes available.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                );
              }

              final quizzes = widget.quizId != null
                  ? snapshot.data!.where((q) => q.id == widget.quizId).toList()
                  : widget.bookId != null
                      ? snapshot.data!
                          .where((q) => q.bookId == widget.bookId)
                          .toList()
                      : snapshot.data!
                          .where((q) => _filterType == 'general'
                              ? q.type == 'general'
                              : q.type != 'general')
                          .toList();

              if (quizzes.isEmpty) {
                return Center(
                  child: Text(
                    widget.bookId != null
                        ? 'No quizzes found for this book.'
                        : _filterType == 'general'
                            ? 'No general quizzes found.'
                            : 'No book quizzes found.',
                  ),
                );
              }

              final currentQuiz = quizzes[_currentQuizIndex];
              final questions = currentQuiz.questions;

              if (questions == null || questions.isEmpty) {
                return const Center(child: Text('No questions in this quiz.'));
              }

              final question = questions[_currentQuestionIndex];

              return Column(
                children: [
                  _buildAppBar(context, currentQuiz.id),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProgressSection(
                            context,
                            _currentQuizIndex + 1,
                            quizzes.length,
                          ),
                          _buildQuestionCard(context, question.questionText),
                          if (question.imageUrl != null) ...[
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(question.imageUrl!),
                              ),
                            ),
                          ],
                          _buildOptions(context, question.options, question.correctOptionIndex),
                          if (_hasCheckedAnswer) _buildExplanationBox(question.explanation),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomSheet: _isSubmitting
          ? const LinearProgressIndicator()
          : _buildBottomButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context, String quizId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppTheme.textMutedDark,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Quiz Session',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, int current, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${((current - 1) / total * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (current - 1) / total,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).cardTheme.shadowColor ?? Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, List<QuizOption> options, int correctIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedOption == index;
          bool isCorrectOption = index == correctIndex;
          
          Color borderColor = Colors.transparent;
          Color bgColor = Theme.of(context).cardColor;
          
          if (_hasCheckedAnswer) {
             if (isCorrectOption) {
               borderColor = AppTheme.accent2; // Green
               bgColor = AppTheme.accent2.withOpacity(0.1);
             } else if (isSelected) {
               borderColor = AppTheme.accent3; // Red
               bgColor = AppTheme.accent3.withOpacity(0.1);
             }
          } else if (isSelected) {
             borderColor = AppTheme.primary;
             bgColor = AppTheme.primary.withOpacity(0.05);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: AnimatedScaleButton(
              onTap: () {
                if (!_hasCheckedAnswer) {
                  setState(() => _selectedOption = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(
                    color: borderColor == Colors.transparent ? Colors.grey.withOpacity(0.3) : borderColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        options[index].text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected || (_hasCheckedAnswer && isCorrectOption) ? FontWeight.bold : FontWeight.w500,
                          color: _hasCheckedAnswer && isCorrectOption ? AppTheme.accent2 : null,
                        ),
                      ),
                    ),
                    if (_hasCheckedAnswer && isCorrectOption)
                      const Icon(Icons.check_circle, color: AppTheme.accent2)
                    else if (_hasCheckedAnswer && isSelected && !isCorrectOption)
                      const Icon(Icons.cancel, color: AppTheme.accent3)
                    else 
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: isSelected ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary,
                            ),
                          ),
                        ) : null,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExplanationBox(String? explanation) {
    if (explanation == null || explanation.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Explanation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? AppTheme.accent : Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FutureBuilder<List<Quiz>>(
            future: _quizzesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const SizedBox.shrink();

              final quizzes = widget.quizId != null
                  ? snapshot.data!.where((q) => q.id == widget.quizId).toList()
                  : widget.bookId != null
                      ? snapshot.data!
                          .where((q) => q.bookId == widget.bookId)
                          .toList()
                      : snapshot.data!
                          .where((q) => _filterType == 'general'
                              ? q.type == 'general'
                              : q.type != 'general')
                          .toList();

              if (quizzes.isEmpty) return const SizedBox.shrink();

              final currentQuiz = quizzes[_currentQuizIndex];
              final isLastQuestion = _currentQuestionIndex >= (currentQuiz.questions?.length ?? 0) - 1;
              final isLastQuiz = _currentQuizIndex >= quizzes.length - 1;

              String buttonText = "Check Answer";
              if (_hasCheckedAnswer) {
                if (isLastQuestion && isLastQuiz) {
                  buttonText = "Finish Quiz";
                } else {
                  buttonText = "Next Question";
                }
              }

              return ElevatedButton(
                onPressed: _selectedOption != null
                    ? () => _handleBottomButtonTap(quizzes)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasCheckedAnswer ? AppTheme.primary : AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _selectedOption != null ? 4 : 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
