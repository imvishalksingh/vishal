import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-screen premium background with deep gradient + radial glow orbs.
/// The colored orbs give BackdropFilter widgets real content to blur against,
/// making the glassmorphic effect actually visible.
class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // ── Base gradient ─────────────────────────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF080B14),
                        Color(0xFF0A0E1C),
                        Color(0xFF0D1225),
                      ]
                    : const [
                        Color(0xFFF0F4FF),
                        Color(0xFFEEF2FF),
                        Color(0xFFF8FAFF),
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // ── Top-right Indigo glow orb ─────────────────────────────────────
        Positioned(
          top: -80,
          right: -60,
          child: _GlowOrb(
            color: isDark
                ? AppTheme.primary.withValues(alpha: 0.18)
                : AppTheme.primary.withValues(alpha: 0.07),
            size: 280,
          ),
        ),

        // ── Bottom-left Amber glow orb ────────────────────────────────────
        Positioned(
          bottom: 80,
          left: -80,
          child: _GlowOrb(
            color: isDark
                ? AppTheme.accent.withValues(alpha: 0.10)
                : AppTheme.accent.withValues(alpha: 0.05),
            size: 220,
          ),
        ),

        // ── Centre accent orb ────────────────────────────────────────────
        Positioned(
          top: 300,
          right: 40,
          child: _GlowOrb(
            color: isDark
                ? AppTheme.accent2.withValues(alpha: 0.05)
                : AppTheme.accent2.withValues(alpha: 0.03),
            size: 160,
          ),
        ),

        // ── Child content ────────────────────────────────────────────────
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
