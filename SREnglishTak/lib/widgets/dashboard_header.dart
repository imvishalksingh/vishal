import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? bottomChild;
  final IconData actionIcon;
  final VoidCallback? onActionPressed;
  final bool showProfileIcon;
  final bool? showBackButton;

  const DashboardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.bottomChild,
    this.actionIcon = Icons.account_circle_rounded,
    this.onActionPressed,
    this.showProfileIcon = true,
    this.showBackButton,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPop = showBackButton ?? Navigator.canPop(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6200EE),
            Color(0xFF9E77ED),
            Color(0xFFF9F5FF),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Top Row: Logo & Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  if (canPop)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  Image.asset(
                    'assets/icons/logo.png',
                    width: 120,
                    height: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.school, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  if (showProfileIcon)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(actionIcon, color: Colors.white, size: 24),
                        onPressed: onActionPressed,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
            if (bottomChild != null) ...[
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: bottomChild!,
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
