import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/challenge.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/springy_scale_button.dart';
import 'challenge_briefing_screen.dart';
import 'leaderboard_screen.dart';

class ArenaScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const ArenaScreen({super.key, this.onProfileTap});

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  late Future<List<Challenge>> _challengesFuture;

  @override
  void initState() {
    super.initState();
    _challengesFuture = ApiService.getChallenges();
  }

  Future<void> _refresh() async {
    setState(() => _challengesFuture = ApiService.getChallenges());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            DashboardHeader(
              title: 'Practice Arena',
              subtitle: 'Compete, win XP, and climb the ranks',
              isDashboard: false,
              onActionPressed: widget.onProfileTap,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppTheme.primary,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // ── Leaderboard banner ───────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _LeaderboardBanner(isDark: isDark)
                            .animate()
                            .fadeIn(duration: 350.ms)
                            .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOutCubic),
                      ),
                    ),

                    // ── Section header ───────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'ACTIVE CHALLENGES',
                          style: GoogleFonts.inter(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                      ),
                    ),

                    // ── Challenges list ──────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                      sliver: _ChallengesList(
                        future: _challengesFuture,
                        onRefresh: _refresh,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leaderboard Banner
// ─────────────────────────────────────────────────────────────────────────────
class _LeaderboardBanner extends StatelessWidget {
  final bool isDark;
  const _LeaderboardBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SpringyScaleButton(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      ),
      child: GlassPanel(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global XP Leaderboard',
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'See the top learners ranked by XP',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Challenges List Sliver
// ─────────────────────────────────────────────────────────────────────────────
class _ChallengesList extends StatelessWidget {
  final Future<List<Challenge>> future;
  final VoidCallback onRefresh;
  final bool isDark;

  const _ChallengesList({
    required this.future,
    required this.onRefresh,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<Challenge>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(error: snapshot.error.toString(), onRetry: onRefresh, isDark: isDark);
          }

          final all = snapshot.data ?? [];
          final challenges = all.where((c) {
            if (c.endTime == null) return true;
            return DateTime.now().toUtc().isBefore(c.endTime!.toUtc());
          }).toList();

          if (challenges.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          return Column(
            children: List.generate(challenges.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _ChallengeCard(challenge: challenges[i], isDark: isDark)
                    .animate()
                    .fadeIn(delay: (i * 80).ms, duration: 380.ms)
                    .slideY(begin: 0.1, duration: 380.ms, curve: Curves.easeOutCubic),
              );
            }),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Challenge Card
// ─────────────────────────────────────────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool isDark;

  const _ChallengeCard({required this.challenge, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool done = challenge.hasSubmitted;

    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header image / gradient banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  if (challenge.imageUrl != null)
                    Image.network(
                      challenge.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  // Decorative icon
                  Center(
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 90,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${challenge.durationMinutes ?? 0} min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Completed badge
                  if (done)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent2,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'DONE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.name,
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppTheme.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.description ?? 'Put your skills to the test and earn XP rewards.',
                  style: GoogleFonts.inter(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: done
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChallengeBriefingScreen(
                                  challenge: challenge,
                                ),
                              ),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: done ? Colors.transparent : AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.transparent,
                      elevation: done ? 0 : 0,
                      shadowColor: AppTheme.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: done
                            ? BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.black.withValues(alpha: 0.08),
                              )
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      done ? 'Already Attempted' : 'Start Challenge',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: done
                            ? (isDark ? Colors.grey.shade500 : Colors.grey.shade500)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty & Error states
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'No Active Challenges',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New challenges will appear here.\nCheck back soon.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorState({required this.error, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.accent3.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, color: AppTheme.accent3, size: 36),
          ),
          const SizedBox(height: 18),
          Text(
            'Could not load challenges',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: Text('Retry', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
