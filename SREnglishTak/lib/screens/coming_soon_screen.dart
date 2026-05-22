import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/bouncy_button.dart';

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

class _ComingSoonScreenState extends State<ComingSoonScreen> with SingleTickerProviderStateMixin {
  bool _isSubscribed = false;
  bool _isExcited = false;
  int _excitedCount = 148;
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _toggleExcited() {
    setState(() {
      _isExcited = !_isExcited;
      if (_isExcited) {
        _excitedCount++;
        _heartController.forward().then((_) => _heartController.reverse());
      } else {
        _excitedCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DashboardHeader(
            title: widget.title,
            onActionPressed: widget.onProfileTap,
          ),
          Expanded(
            child: PremiumBackground(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Continuous subtle floating animation for abstract icon
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 8.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: child,
                          );
                        },
                        // Infinite oscillation curve
                        onEnd: () {},
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.12),
                                AppTheme.primary.withOpacity(0.02),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.rocket_launch_rounded,
                                  size: 40,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Upper badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.12)),
                        ),
                        child: const Text(
                          'UNDER DEVELOPMENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Coming Soon text
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // High-end informative description paragraph
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'We are building an exceptionally refined learning module designed to accelerate your English preparation. Stay tuned as we finalize the curriculum.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Custom glass checklist showing what to expect
                      GlassPanel(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WHAT TO EXPECT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white70 : Colors.black54,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildExpectationRow(Icons.bolt_rounded, 'Premium Mock Test Papers', 'Fully solved expert walkthroughs'),
                            const SizedBox(height: 12),
                            _buildExpectationRow(Icons.auto_awesome_rounded, 'Bite-Sized Grammar Hubs', 'Learn concepts efficiently on the go'),
                            const SizedBox(height: 12),
                            _buildExpectationRow(Icons.insights_rounded, 'Smarter Progress Insights', 'Track your board exam preparation level'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Notification subscription section with AnimatedSwitcher
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isSubscribed
                            ? Container(
                                key: const ValueKey('subscribed_container'),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent2.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.accent2.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppTheme.accent2, size: 24),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Subscription Active! We\'ll ping you when this goes live.',
                                        style: TextStyle(
                                          color: AppTheme.accent2.withOpacity(0.9),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                key: const ValueKey('notify_button_container'),
                                width: double.infinity,
                                child: BouncyButton(
                                  label: 'Notify Me When Ready',
                                  icon: Icons.notifications_active_outlined,
                                  color: AppTheme.primary,
                                  borderRadius: 20,
                                  onTap: () {
                                    setState(() {
                                      _isSubscribed = true;
                                    });
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Interactive "Excited?" like/vote container
                      GestureDetector(
                        onTap: _toggleExcited,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isExcited
                                ? AppTheme.accent3.withOpacity(0.08)
                                : (isDark ? Colors.white10 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: _isExcited ? AppTheme.accent3.withOpacity(0.2) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _heartController,
                                child: Icon(
                                  _isExcited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: _isExcited ? AppTheme.accent3 : Colors.grey.shade500,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Excited?  •  $_excitedCount votes',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _isExcited ? AppTheme.accent3 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Minimal outlined "Go Back" button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Go Back',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationRow(IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
