import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import 'challenge_quiz_screen.dart';
import 'challenge_leaderboard_screen.dart';

class ChallengeBriefingScreen extends StatelessWidget {
  final Challenge challenge;

  const ChallengeBriefingScreen({super.key, required this.challenge});

  void _startChallenge(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChallengeQuizScreen(challenge: challenge)),
    );
  }

  void _viewLeaderboard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChallengeLeaderboardScreen(challenge: challenge)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.1),
                          image: challenge.imageUrl != null
                              ? DecorationImage(image: NetworkImage(challenge.imageUrl!), fit: BoxFit.cover)
                              : null,
                          border: Border.all(color: AppTheme.primary, width: 4),
                        ),
                        child: challenge.imageUrl == null
                            ? const Icon(Icons.emoji_events, size: 60, color: AppTheme.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        challenge.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.backgroundDark,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (challenge.description != null)
                      Center(
                        child: Text(
                          challenge.description!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 32),
                    
                    const Text('RULES & REWARDS', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    GlassPanel(
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: [
                          _ruleRow(Icons.timer_outlined, 'Time Limit', '${challenge.durationMinutes} Minutes'),
                          const Divider(height: 24),
                          _ruleRow(Icons.quiz_outlined, 'Questions', '${challenge.questions.length} Questions'),
                          const Divider(height: 24),
                          _ruleRow(Icons.looks_one_outlined, 'Attempts', '1 Attempt Only'),
                          const Divider(height: 24),
                          _ruleRow(Icons.star_rounded, 'Reward', challenge.prizeText ?? 'Glory & Rank', color: Colors.amber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    challenge.hasSubmitted 
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                  SizedBox(width: 8),
                                  Text('CHALLENGE COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "You have already attempted this challenge. You can view the final leaderboard to see your standing.",
                                style: TextStyle(color: Colors.green, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 8),
                                  Text('IMPORTANT DISCLAIMER', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Once you start this challenge, you cannot go back. If you exit the app or press back, your challenge will be submitted immediately with 0 score, and you will not be allowed to enter again.",
                                style: TextStyle(color: Colors.redAccent, fontSize: 12, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                    
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _viewLeaderboard(context),
                        icon: const Icon(Icons.leaderboard_rounded),
                        label: const Text('View Current Leaderboard'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: challenge.hasSubmitted 
                ? () => _viewLeaderboard(context)
                : () => _startChallenge(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: challenge.hasSubmitted ? AppTheme.accent2 : AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
            ),
            child: Text(
              challenge.hasSubmitted ? 'VIEW LEADERBOARD' : 'START CHALLENGE NOW', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleRow(IconData icon, String title, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? AppTheme.primary, size: 24),
        const SizedBox(width: 16),
        Text(title, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      ],
    );
  }
}
