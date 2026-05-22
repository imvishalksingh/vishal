import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        gradient: LinearGradient(
          colors: isDark 
            ? [
                const Color(0xFF0F172A), // Slate 900
                const Color(0xFF1E293B), // Slate 800
              ] 
            : [
                const Color(0xFFF8FAFC), // Slate 50
                const Color(0xFFF1F5F9), // Slate 100
              ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
