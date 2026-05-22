import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user_achievement.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/xp_provider.dart';
import '../widgets/animated_scale_button.dart';
import 'admin_shell.dart';
import '../widgets/glass_panel.dart';
import 'edit_profile_screen.dart';
import 'bookmarks_screen.dart';
import 'reading_history_screen.dart';
import 'settings_screen.dart';
import 'quiz_history_screen.dart';

import '../widgets/dashboard_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userDataProvider = context.watch<UserDataProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 4),
                        color: AppTheme.primary.withOpacity(0.1),
                        image: user?['avatar_url'] != null && user!['avatar_url']!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(user['avatar_url']!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?['avatar_url'] == null || user!['avatar_url']!.isEmpty
                          ? const Icon(Icons.person, color: AppTheme.primary, size: 52)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: AppTheme.backgroundDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?['full_name'] ?? 'Guest User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (authProvider.isLoggedIn)
                    if (userDataProvider.achievements != null)
                      Image.asset(_getBadgeImageForCount(userDataProvider.achievements!.achievements.length), width: 32, height: 32),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user?['email'] ?? 'No email available',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              if (authProvider.isLoggedIn) ...[
                (() {
                  final className = user?['class'] as String?;
                  final learningGoal = user?['learning_goal'] as String?;
                  if ((className == null || className.trim().isEmpty) &&
                      (learningGoal == null || learningGoal.trim().isEmpty)) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (className != null && className.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.school, size: 14, color: AppTheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  className,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (learningGoal != null && learningGoal.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.teal.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Colors.teal),
                                const SizedBox(width: 6),
                                Text(
                                  learningGoal,
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                })(),
              ],
              const SizedBox(height: 32),
              if (authProvider.isLoggedIn)
                if (userDataProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: LinearProgressIndicator(),
                  )
                else if (userDataProvider.achievements != null)
                  Column(
                    children: [
                      _buildInsightsCard(context, userDataProvider),
                      const SizedBox(height: 16),
                      _buildXpLevelCard(context),
                      const SizedBox(height: 16),
                      _buildAchievementsCard(context, userDataProvider.achievements!),
                      const SizedBox(height: 24),
                    ],
                  ),
            _buildProfileTile(
              context,
              Icons.person_outline,
              'Edit Profile',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _buildProfileTile(
              context,
              Icons.history,
              'Reading History',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingHistoryScreen())),
            ),
            _buildProfileTile(
              context,
              Icons.quiz_outlined,
              'Quiz History',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHistoryScreen())),
            ),
            _buildProfileTile(
              context,
              Icons.bookmark_outline,
              'Bookmarks',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())),
            ),
            _buildProfileTile(
              context,
              Icons.settings_outlined,
              'Settings',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
              if (authProvider.isAdmin) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildProfileTile(
                  context,
                  Icons.admin_panel_settings_outlined,
                  'Admin Control Panel',
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminShell())),
                  isSpecial: true,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  ),
);
}

  Widget _buildHeader(BuildContext context) {
    return DashboardHeader(
      title: 'Profile',
      subtitle: 'Manage your account & stats',
      actionIcon: Icons.logout_rounded,
      onActionPressed: () async {
        await context.read<AuthProvider>().logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      },
    );
  }

  Widget _buildProfileTile(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AnimatedScaleButton(
        onTap: onTap,
        child: GlassPanel(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Icon(icon, color: isSpecial ? AppTheme.primary : Colors.grey),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSpecial ? AppTheme.primary : null,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsCard(BuildContext context, UserDataProvider provider) {
    final summary = provider.achievements!.summary;
    final booksCompleted = provider.progress.where((p) => p.isCompleted).length;
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _metricColumn('Streak', '${summary.currentStreak}d')),
              Expanded(child: _metricColumn('Today', '${summary.readingMinutesToday}m')),
              Expanded(child: _metricColumn('Badges', '${provider.achievements!.achievements.length}')),
              Expanded(child: _metricColumn('Books', '$booksCompleted')),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final name = context.read<AuthProvider>().user?['full_name'] ?? 'Reader';
                Share.share(
                  '🔥 ${name}\'s ${summary.currentStreak}-day streak on SR English Tak!\n'
                  'I\'ve read ${summary.readingMinutesToday} minutes today and unlocked ${provider.achievements!.achievements.length} badges.\n'
                  'Join me in learning English with Reading, Quizzes & Vocabulary!',
                );
              },
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('Share My Progress'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpLevelCard(BuildContext context) {
    final xp = context.watch<XpProvider>();
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  xp.levelTitle.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${xp.totalXp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xp.progressToNextLevel,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${xp.xpForCurrentLevel} XP',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              Text(
                '${xp.xpForNextLevel} XP to next level',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, UserAchievementBundle bundle) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (bundle.achievements.isEmpty)
            const Text(
              'No achievements unlocked yet. Keep reading and taking quizzes.',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...bundle.achievements.map(
              (achievement) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          _getBadgeImageForCount(bundle.achievements.indexOf(achievement) + 1),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            achievement.description,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _metricColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  String _getBadgeImageForCount(int count) {
    if (count >= 10) return 'assets/icons/level-4.png';
    if (count >= 6) return 'assets/icons/level-3.png';
    if (count >= 3) return 'assets/icons/level-2.png';
    return 'assets/icons/level-1.png';
  }
}
