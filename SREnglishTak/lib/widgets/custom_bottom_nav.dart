import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Floating frosted-glass bottom navigation pill.
/// 5 tabs: Home | Tests | [Arena centre] | Library | Profile
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottom + 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, label: 'Home',    activeIcon: Icons.home_rounded,       inactiveIcon: Icons.home_outlined,           currentIndex: currentIndex, onTap: onTap, isDark: isDark),
                _NavItem(index: 1, label: 'Tests',   activeIcon: Icons.assignment_rounded,  inactiveIcon: Icons.assignment_outlined,      currentIndex: currentIndex, onTap: onTap, isDark: isDark),
                _CentreArenaButton(currentIndex: currentIndex, onTap: onTap, isDark: isDark),
                _NavItem(index: 2, label: 'Library', activeIcon: Icons.local_library_rounded, inactiveIcon: Icons.local_library_outlined, currentIndex: currentIndex, onTap: onTap, isDark: isDark),
                _NavItem(index: 4, label: 'Profile', activeIcon: Icons.person_rounded,       inactiveIcon: Icons.person_outline,          currentIndex: currentIndex, onTap: onTap, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Regular nav item ──────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _NavItem({
    required this.index,
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentIndex == index;
    final Color active   = AppTheme.primary;
    final Color inactive = isDark ? Colors.grey.shade500 : Colors.grey.shade500;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.all(selected ? 8 : 6),
              decoration: BoxDecoration(
                color: selected
                    ? active.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? activeIcon : inactiveIcon,
                color: selected ? active : inactive,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: selected ? active : inactive,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centre Arena button (elevated pill) ───────────────────────────────────────
class _CentreArenaButton extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _CentreArenaButton({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentIndex == 3;

    return GestureDetector(
      onTap: () => onTap(3),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              width: selected ? 48 : 44,
              height: selected ? 48 : 44,
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [AppTheme.primary, Color(0xFF818CF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: 0.10),
                                Colors.white.withValues(alpha: 0.06),
                              ]
                            : [
                                Colors.black.withValues(alpha: 0.06),
                                Colors.black.withValues(alpha: 0.03),
                              ],
                      ),
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.40),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.bolt_rounded,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Arena',
              style: TextStyle(
                color: selected
                    ? AppTheme.primary
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          .animate(target: selected ? 1 : 0)
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms),
    );
  }
}
