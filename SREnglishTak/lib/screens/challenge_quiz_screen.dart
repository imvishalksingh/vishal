import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';
import '../providers/xp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import 'challenge_leaderboard_screen.dart';

class ChallengeQuizScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeQuizScreen({super.key, required this.challenge});

  @override
  State<ChallengeQuizScreen> createState() => _ChallengeQuizScreenState();
}

class _ChallengeQuizScreenState extends State<ChallengeQuizScreen> {
  int _currentIndex = 0;
  late List<int?> _selectedAnswers;
  late Stopwatch _stopwatch;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.challenge.questions.length, null);
    _remainingSeconds = (widget.challenge.durationMinutes ?? 5) * 60;
    _stopwatch = Stopwatch()..start();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitChallenge(); // Auto-submit when time is up
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _submitChallenge() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();
    _stopwatch.stop();

    int score = 0;
    for (int i = 0; i < widget.challenge.questions.length; i++) {
      if (_selectedAnswers[i] == widget.challenge.questions[i].correctOptionIndex) {
        score += 10; // 10 points per correct answer
      }
    }

    try {
      await ApiService.submitChallengeAttempt(
        widget.challenge.id,
        score,
        _stopwatch.elapsedMilliseconds,
      );

      // Award global XP
      if (mounted) {
        context.read<XpProvider>().awardXp(score, 'Challenge Arena');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChallengeLeaderboardScreen(challenge: widget.challenge)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isSubmitting = false);
    }
  }

  Future<bool> _onWillPop() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Challenge?'),
        content: const Text('If you leave now, your attempt will be submitted as is (0 if no answers) and you cannot retry!'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('STAY')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('QUIT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (quit) {
      // Auto-submit current progress so they are locked out
      await _submitChallenge();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.challenge.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No questions available.')));
    }

    final question = widget.challenge.questions[_currentIndex];
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _remainingSeconds < 60 ? Colors.redAccent.withOpacity(0.2) : AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: _remainingSeconds < 60 ? Colors.redAccent : AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  timeString,
                  style: TextStyle(
                    color: _remainingSeconds < 60 ? Colors.redAccent : AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
        body: PremiumBackground(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: List.generate(
                    widget.challenge.questions.length,
                    (index) => Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: index <= _currentIndex
                              ? AppTheme.primary
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'QUESTION ${_currentIndex + 1} OF ${widget.challenge.questions.length}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      question.questionText,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(question.options.length, (i) {
                      final isSelected = _selectedAnswers[_currentIndex] == i;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[_currentIndex] = i;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primary : Colors.grey,
                                      width: isSelected ? 8 : 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    question.options[i],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        IconButton(
                          onPressed: () => setState(() => _currentIndex--),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          padding: const EdgeInsets.all(16),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedAnswers[_currentIndex] == null || _isSubmitting
                              ? null
                              : () {
                                  if (_currentIndex < widget.challenge.questions.length - 1) {
                                    setState(() => _currentIndex++);
                                  } else {
                                    _submitChallenge();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _currentIndex == widget.challenge.questions.length - 1
                                      ? 'SUBMIT ANSWERS'
                                      : 'NEXT QUESTION',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
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
}
