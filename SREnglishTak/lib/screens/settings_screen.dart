import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import 'legal_page_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'PREFERENCES',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      context: context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'SUPPORT',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLinkTile(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & FAQ',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPageScreen(
                            title: 'Help & FAQ',
                            content: _helpContent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkTile(
                      context: context,
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPageScreen(
                            title: 'Privacy Policy',
                            content: _privacyContent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLinkTile(
                      context: context,
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalPageScreen(
                            title: 'Terms of Service',
                            content: _termsContent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        'SR English Tak v1.0.0',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Legal content strings ────────────────────────────────────────────────────

const String _helpContent = '''
## Frequently Asked Questions

**Q: How do I start reading a book?**
Go to the Library tab, tap any book, and it opens directly in the reader.

**Q: How do I track my reading progress?**
Your progress is saved automatically every time you read. Check the Home screen for your "Continue Reading" card or view your stats on the Profile tab.

**Q: How do quizzes work?**
Go to the Quiz tab, choose a quiz, and answer the multiple-choice questions. Your score is saved to your history.

**Q: What is the Daily Challenge?**
Every day a new vocabulary word is featured on the Home screen. Tap it to explore the full Vocabulary Builder.

**Q: How do I earn badges?**
Badges are earned by completing quizzes, maintaining reading streaks, and hitting reading milestones.

**Q: How do I contact support?**
Email us at support@srenglishtak.com and we'll respond within 24–48 hours.
''';

const String _privacyContent = '''
## Privacy Policy

**Last updated: April 2026**

SR English Tak ("we", "our", or "us") is committed to protecting your privacy.

**Information We Collect**
- Account information (name, email) via Google Sign-In
- Reading progress and session data to track your learning
- Quiz scores and achievements

**How We Use Your Information**
- To personalize your learning experience
- To show you relevant book and quiz recommendations
- To track streaks, badges, and progress across sessions

**Data Storage**
Your data is stored securely on our backend servers. We do not sell your data to third parties.

**Google Sign-In**
We use Google Sign-In for authentication. Please refer to Google's Privacy Policy for details on how they handle your data.

**Your Rights**
You may delete your account and all associated data at any time by contacting support@srenglishtak.com.

**Contact Us**
For privacy-related queries: privacy@srenglishtak.com
''';

const String _termsContent = '''
## Terms of Service

**Last updated: April 2026**

By using SR English Tak, you agree to these terms.

**Use of the App**
- This app is intended for personal, educational use only.
- You must be at least 13 years old to use this app.
- You agree not to misuse the app or attempt to access admin features without authorization.

**Content**
- Books and educational materials provided in this app are for learning purposes only.
- All content is owned by SR English Tak or its content partners.

**Account**
- You are responsible for maintaining the security of your account.
- We reserve the right to suspend accounts that violate these terms.

**Disclaimer**
This app is provided "as is" without warranties of any kind. We are not liable for any damages arising from the use of this app.

**Changes to Terms**
We may update these terms at any time. Continued use of the app after changes constitutes acceptance.

**Contact**
legal@srenglishtak.com
''';
