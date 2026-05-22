import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/xp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class QuizResults extends StatefulWidget {
  final int score;
  final int total;
  final String quizTitle;
  final String quizId;
  const QuizResults({
    super.key,
    required this.score,
    required this.total,
    this.quizTitle = 'Quiz',
    this.quizId = '',
  });

  @override
  State<QuizResults> createState() => _QuizResultsState();
}

class _QuizResultsState extends State<QuizResults> {
  bool _xpAwarded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCompletion());
  }

  Future<void> _handleCompletion() async {
    final xp = context.read<XpProvider>();

    // Save quiz result + award XP
    await xp.saveQuizResult(
      quizId: widget.quizId,
      quizTitle: widget.quizTitle,
      score: widget.score,
      total: widget.total,
    );

    if (mounted) {
      setState(() => _xpAwarded = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text('+50 XP earned!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Trigger in-app review after 3rd quiz
    if (xp.quizCount >= 3) {
      try {
        final inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
      } catch (_) {
        // Silently fail on platforms that don't support it
      }
    }
  }

  int get score => widget.score;
  int get total => widget.total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      _buildProgressRing(context),
                      _buildMotivationalMessage(context),
                      _buildPerformanceBreakdown(context),
                      _buildActionButtons(context),
                      _buildFooterDecoration(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Quiz Results',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressRing(BuildContext context) {
    final double percentage = score / (total == 0 ? 1 : total);
    return Column(
      children: [
        SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 12,
                color: AppTheme.primary.withOpacity(0.1),
              ),
              CircularProgressIndicator(
                value: percentage,
                strokeWidth: 12,
                color: AppTheme.primary,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score/$total',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'CORRECT',
                      style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(BuildContext context) {
    final double percentage = score / (total == 0 ? 1 : total);
    String message = percentage >= 0.7 ? 'Great Job!' : (percentage >= 0.4 ? 'Good Effort!' : 'Keep Practicing!');
    String subtext = percentage >= 0.7 
        ? 'You\'re mastering your reading goals. Keep up the scholarly work!'
        : 'Review the text and try again to improve your score.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: Column(
        children: [
          Text(message, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtext, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int wrong = total - score;
    final double percentage = (score / (total == 0 ? 1 : total)) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(isDark ? 0.12 : 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildStatRow(Icons.check_circle, 'Correct', score.toString(), Colors.green),
          const SizedBox(height: 16),
          _buildStatRow(Icons.cancel, 'Wrong', wrong.toString(), Colors.red),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.grey, height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accuracy Score', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              Text('${percentage.toInt()}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final percent = (score / (total == 0 ? 1 : total) * 100).round();
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.backgroundDark,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.library_books),
              label: const Text('Back to Home',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Share.share(
                  '🎯 I just scored $percent% on "${widget.quizTitle}" on SR English Tak! '
                  'Learn English with Reading, Quizzes & Vocabulary. Join me! 📖',
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share Result'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterDecoration(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48.0),
      child: Opacity(
        opacity: 0.2,
        child: Icon(Icons.school, size: 48, color: Colors.grey),
      ),
    );
  }
}
