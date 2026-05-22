import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../models/quiz.dart';

class QuizAnswerReview extends StatelessWidget {
  final String questionText;
  final List<QuizOption> options;
  final int selectedIndex;
  final int correctIndex;
  final String? explanation;

  const QuizAnswerReview({
    super.key,
    required this.questionText,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedIndex == correctIndex;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.primary),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isCorrect ? Colors.green.withOpacity(0.6) : Colors.redAccent.withOpacity(0.6),
                        ),
                      ),
                      child: Text(
                        isCorrect ? 'Correct' : 'Incorrect',
                        style: TextStyle(
                          color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GlassPanel(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(18),
                        child: Text(
                          questionText,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...options.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final option = entry.value;
                        final isSelected = idx == selectedIndex;
                        final isCorrectOption = idx == correctIndex;
                        final borderColor = isCorrectOption
                            ? Colors.greenAccent
                            : isSelected
                                ? Colors.redAccent
                                : Colors.white.withOpacity(0.12);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isCorrectOption
                                ? [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : [],
                          ),
                          child: GlassPanel(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            borderRadius: BorderRadius.circular(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: isCorrectOption
                                      ? Colors.greenAccent.withOpacity(0.2)
                                      : isSelected
                                          ? Colors.redAccent.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.08),
                                  child: Text(
                                    option.label,
                                    style: TextStyle(
                                      color: isCorrectOption
                                          ? Colors.greenAccent
                                          : isSelected
                                              ? Colors.redAccent
                                              : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.text,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      if (explanation != null && explanation!.trim().isNotEmpty)
                        GlassPanel(
                          padding: const EdgeInsets.all(18),
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Explanation',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                              ),
                              const SizedBox(height: 8),
                              Text(explanation!),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.backgroundDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
