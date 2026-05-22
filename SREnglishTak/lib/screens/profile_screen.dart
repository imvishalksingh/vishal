import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_achievement.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/xp_provider.dart';
import '../widgets/springy_scale_button.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/dashboard_header.dart';
import 'admin_shell.dart';
import 'edit_profile_screen.dart';
import 'bookmarks_screen.dart';
import 'reading_history_screen.dart';
import 'settings_screen.dart';
import 'quiz_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userData = context.watch<UserDataProvider>();
    final xp = context.watch<XpProvider>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            DashboardHeader(
              title: 'Profile',
              subtitle: 'Your account & progress',
              isDashboard: false,
              showProfileIcon: true,
              actionIcon: Icons.logout_rounded,
              onActionPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              },
            ),

            // ── Scrollable body ─────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Avatar hero card
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: _AvatarCard(user: user, auth: auth, isDark: isDark)
                          .animate()
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.08, duration: 380.ms, curve: Curves.easeOutCubic),
                    ),
                  ),

                  // Stats row
                  if (auth.isLoggedIn && userData.achievements != null) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _StatsGrid(
                          userData: userData,
                          xp: xp,
                          isDark: isDark,
                          onShare: () => _shareProgress(context, auth, userData),
                        )
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 350.ms)
                            .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic),
                      ),
                    ),

                    // XP progress
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      sliver: SliverToBoxAdapter(
                        child: _XpCard(xp: xp, isDark: isDark)
                            .animate()
                            .fadeIn(delay: 140.ms, duration: 350.ms)
                            .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic),
                      ),
                    ),
                  ],

                  // Action menu
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'ACCOUNT',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: GlassPanel(
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: _buildMenuItems(context, auth, isDark),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 220.ms, duration: 350.ms)
                          .slideY(begin: 0.06, duration: 350.ms, curve: Curves.easeOutCubic),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 140),
                    sliver: SliverToBoxAdapter(child: SizedBox()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context, AuthProvider auth, bool isDark) {
    final items = [
      _MenuItem(icon: Icons.person_outline_rounded,  label: 'Edit Profile',     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
      _MenuItem(icon: Icons.history_rounded,          label: 'Reading History',  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingHistoryScreen()))),
      _MenuItem(icon: Icons.quiz_outlined,            label: 'Quiz History',     onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHistoryScreen()))),
      _MenuItem(icon: Icons.bookmark_outline_rounded, label: 'Bookmarks',        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()))),
      _MenuItem(icon: Icons.settings_outlined,        label: 'Settings',         onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), isLast: !auth.isAdmin),
      if (auth.isAdmin)
        _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell())), isSpecial: true, isLast: true),
    ];
    return items.map((item) => _buildMenuTile(context, item, isDark)).toList();
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem item, bool isDark) {
    return SpringyScaleButton(
      onTap: item.onTap,
      child: Container(
        decoration: item.isLast
            ? null
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: item.isSpecial
                      ? AppTheme.primary.withValues(alpha: 0.10)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: item.isSpecial
                      ? AppTheme.primary
                      : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.outfit(
                    color: item.isSpecial
                        ? AppTheme.primary
                        : (isDark ? Colors.white : AppTheme.textDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProgress(BuildContext context, AuthProvider auth, UserDataProvider userData) {
    final name = auth.user?['full_name'] ?? 'A learner';
    final summary = userData.achievements!.summary;
    final badges = userData.achievements!.achievements.length;
    Share.share(
      '🔥 $name\'s ${summary.currentStreak}-day streak on SR English Tak!\n'
      'I\'ve read ${summary.readingMinutesToday} minutes today and unlocked $badges badges.\n'
      'Join me in mastering English with Reading, Quizzes & Vocabulary!',
    );
  }

  String _getBadgeImageForCount(int count) {
    if (count >= 10) return 'assets/icons/level-4.png';
    if (count >= 6) return 'assets/icons/level-3.png';
    if (count >= 3) return 'assets/icons/level-2.png';
    return 'assets/icons/level-1.png';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar Hero Card
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  final Map<String, dynamic>? user;
  final AuthProvider auth;
  final bool isDark;

  const _AvatarCard({required this.user, required this.auth, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final className = user?['class'] as String?;
    final goal = user?['learning_goal'] as String?;
    final avatarUrl = user?['avatar_url'] as String?;
    final name = user?['full_name'] as String? ?? 'Guest User';
    final email = user?['email'] as String? ?? '';

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: 3),
              color: AppTheme.primary.withValues(alpha: 0.10),
              image: avatarUrl != null && avatarUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (avatarUrl == null || avatarUrl.isEmpty)
                ? const Icon(Icons.person_rounded, color: AppTheme.primary, size: 40)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            email,
            style: GoogleFonts.inter(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          if ((className != null && className.trim().isNotEmpty) ||
              (goal != null && goal.trim().isNotEmpty)) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (className != null && className.trim().isNotEmpty)
                  _BadgeChip(
                    label: className,
                    icon: Icons.school_rounded,
                    color: AppTheme.primary,
                  ),
                if (goal != null && goal.trim().isNotEmpty)
                  _BadgeChip(
                    label: goal,
                    icon: Icons.star_rounded,
                    color: AppTheme.accent2,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _BadgeChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Grid
// ─────────────────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final UserDataProvider userData;
  final XpProvider xp;
  final bool isDark;
  final VoidCallback onShare;

  const _StatsGrid({
    required this.userData,
    required this.xp,
    required this.isDark,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final summary = userData.achievements!.summary;
    final booksCompleted = userData.progress.where((p) => p.isCompleted).length;
    final badges = userData.achievements!.achievements.length;

    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Row(
            children: [
              _Metric(label: 'Streak', value: '${summary.currentStreak}d', color: AppTheme.amber,   icon: Icons.local_fire_department_rounded, isDark: isDark),
              _MetricDivider(isDark: isDark),
              _Metric(label: 'XP',     value: '${xp.totalXp}',             color: AppTheme.primary, icon: Icons.diamond_rounded,               isDark: isDark),
              _MetricDivider(isDark: isDark),
              _Metric(label: 'Badges', value: '$badges',                   color: AppTheme.accent3, icon: Icons.military_tech_rounded,          isDark: isDark),
              _MetricDivider(isDark: isDark),
              _Metric(label: 'Books',  value: '$booksCompleted',           color: AppTheme.accent2, icon: Icons.auto_stories_rounded,           isDark: isDark),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded, size: 16),
              label: Text(
                'Share My Progress',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.40),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _Metric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  final bool isDark;
  const _MetricDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// XP Progress Card
// ─────────────────────────────────────────────────────────────────────────────
class _XpCard extends StatelessWidget {
  final XpProvider xp;
  final bool isDark;

  const _XpCard({required this.xp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Text(
                  xp.levelTitle.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${xp.totalXp} XP total',
                style: GoogleFonts.outfit(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: xp.progressToNextLevel,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${xp.xpForCurrentLevel} XP',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
              Text(
                '${xp.xpForNextLevel} XP to next level',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Menu item data class
// ─────────────────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSpecial;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSpecial = false,
    this.isLast = false,
  });
}
