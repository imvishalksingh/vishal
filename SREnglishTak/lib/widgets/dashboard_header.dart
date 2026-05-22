import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Context-aware top header used across all screens.
/// On the main dashboard (when [isDashboard] is true), shows a time-based
/// greeting above the title. On all sub-screens it shows back button + title.
class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? bottomChild;
  final IconData actionIcon;
  final VoidCallback? onActionPressed;
  final bool showProfileIcon;
  final bool? showBackButton;
  /// Set true on the main HomeScreen so the greeting is shown.
  final bool isDashboard;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bottomChild,
    this.actionIcon = Icons.account_circle_rounded,
    this.onActionPressed,
    this.showProfileIcon = true,
    this.showBackButton,
    this.isDashboard = false,
  });

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = showBackButton ?? Navigator.canPop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.55),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ─────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back button
                      if (canPop) ...[
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          isDark: isDark,
                          size: 16,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Title block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isDashboard)
                              Text(
                                _getGreeting(),
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? AppTheme.indigoLight
                                      : AppTheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            if (isDashboard) const SizedBox(height: 2),
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontSize: isDashboard ? 26 : 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle!,
                                style: GoogleFonts.inter(
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Action / Profile button
                      if (showProfileIcon && onActionPressed != null)
                        _CircleIconButton(
                          icon: actionIcon,
                          isDark: isDark,
                          size: 22,
                          onPressed: onActionPressed!,
                          isAccent: true,
                        ),
                    ],
                  ),

                  // ── Optional bottom widget (e.g. search bar) ────────────
                  if (bottomChild != null) ...[
                    const SizedBox(height: 16),
                    bottomChild!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final double size;
  final VoidCallback onPressed;
  final bool isAccent;

  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    required this.size,
    required this.onPressed,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.04),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size,
            color: isAccent
                ? AppTheme.primary
                : (isDark ? Colors.white : AppTheme.textDark),
          ),
        ),
      ),
    );
  }
}
