import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/tap_sparkles.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/parental_gate.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'home_library.dart';
import 'quiz_view.dart';
import 'profile_screen.dart';
import 'admin_shell.dart';

class KidsHomeMap extends StatelessWidget {
  const KidsHomeMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: TapSparkles(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildCard(
                    context,
                    title: 'Read & Listen',
                    subtitle: 'Big stories. Tiny steps.',
                    icon: Icons.menu_book_rounded,
                    color: AppTheme.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    title: 'My Library',
                    subtitle: 'Pick a book to explore.',
                    icon: Icons.library_books_rounded,
                    color: AppTheme.accent2,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeLibrary())),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    title: 'Fun Quiz',
                    subtitle: 'Tap the right answer!',
                    icon: Icons.quiz_rounded,
                    color: AppTheme.accent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizView())),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    title: 'My Profile',
                    subtitle: 'Grown‑ups only.',
                    icon: Icons.person_rounded,
                    color: AppTheme.accent3,
                    onTap: () async {
                      final ok = await showParentalGate(context);
                      if (!ok) return;
                      // ignore: use_build_context_synchronously
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                  if (AuthService.isAdmin) ...[
                    const SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: 'Teacher Zone',
                      subtitle: 'Admin tools',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppTheme.primary,
                      onTap: () async {
                        final ok = await showParentalGate(context);
                        if (!ok) return;
                        // ignore: use_build_context_synchronously
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminShell()));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.accent3, size: 32),
            const SizedBox(width: 8),
            Text(
              'Let\'s Learn English!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a big card to start.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textDark.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncyButton(
      label: title,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }
}
