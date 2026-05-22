import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/springy_scale_button.dart';

class ComingSoonScreen extends StatefulWidget {
  final String title;
  final VoidCallback? onProfileTap;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.onProfileTap,
  });

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  bool _notified = false;
  bool _excited = false;
  int _exciteCount = 148;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            DashboardHeader(
              title: widget.title,
              isDashboard: false,
              onActionPressed: widget.onProfileTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Icon orb ──────────────────────────────────────
                      _buildIconOrb(isDark)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scale(begin: const Offset(0.85, 0.85), duration: 400.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 28),

                      // ── Status badge ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'UNDER DEVELOPMENT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                            letterSpacing: 1.4,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 350.ms)
                          .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: 16),

                      // ── Title ─────────────────────────────────────────
                      Text(
                        'Coming Soon',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 350.ms)
                          .slideY(begin: 0.1, duration: 350.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: 10),

                      // ── Description ───────────────────────────────────
                      Text(
                        'We are building this learning module to help with your preparation. It will be available shortly.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          height: 1.55,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 230.ms, duration: 350.ms)
                          .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: 28),

                      // ── What to expect card ───────────────────────────
                      GlassPanel(
                        padding: const EdgeInsets.all(22),
                        borderRadius: BorderRadius.circular(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WHAT TO EXPECT',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ExpectRow(
                              icon: Icons.description_outlined,
                              title: 'Practice Test Papers',
                              subtitle: 'Fully solved and explained question sets',
                              color: AppTheme.primary,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                            _ExpectRow(
                              icon: Icons.translate_rounded,
                              title: 'Grammar Chapters',
                              subtitle: 'Structured lessons from basics to advanced',
                              color: AppTheme.accent2,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                            _ExpectRow(
                              icon: Icons.bar_chart_rounded,
                              title: 'Progress Tracking',
                              subtitle: 'Monitor your board exam preparation level',
                              color: AppTheme.amber,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 380.ms)
                          .slideY(begin: 0.10, duration: 380.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: 20),

                      // ── Notify button ─────────────────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _notified
                            ? Container(
                                key: const ValueKey('notified'),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent2.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.accent2.withValues(alpha: 0.20),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppTheme.accent2, size: 22),
                                    const SizedBox(width: 10),
                                    Text(
                                      'You\'ll be notified when this goes live',
                                      style: GoogleFonts.inter(
                                        color: isDark
                                            ? Colors.grey.shade200
                                            : AppTheme.textDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('notify'),
                                width: double.infinity,
                                height: 52,
                                child: SpringyScaleButton(
                                  onTap: () => setState(() => _notified = true),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.35),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.notifications_active_outlined,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Notify Me When Ready',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      )
                          .animate()
                          .fadeIn(delay: 380.ms, duration: 350.ms)
                          .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic),

                      const SizedBox(height: 18),

                      // ── Excited pill ──────────────────────────────────
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _excited = !_excited;
                            _exciteCount += _excited ? 1 : -1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          decoration: BoxDecoration(
                            color: _excited
                                ? AppTheme.accent3.withValues(alpha: 0.08)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.04)),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _excited
                                  ? AppTheme.accent3.withValues(alpha: 0.25)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: _excited ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  _excited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _excited
                                      ? AppTheme.accent3
                                      : Colors.grey.shade500,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Excited?  ·  $_exciteCount',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _excited
                                      ? AppTheme.accent3
                                      : (isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 430.ms, duration: 320.ms),

                      const SizedBox(height: 28),

                      // ── Go back ───────────────────────────────────────
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.primary.withValues(alpha: 0.22),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Go Back',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 480.ms, duration: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconOrb(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.primary.withValues(alpha: 0.18),
            AppTheme.primary.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.8)
                : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.rocket_launch_rounded,
                size: 36, color: AppTheme.primary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expect row widget
// ─────────────────────────────────────────────────────────────────────────────
class _ExpectRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _ExpectRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
