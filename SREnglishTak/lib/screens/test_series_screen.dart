import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/glass_panel.dart';

class TestSeriesScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const TestSeriesScreen({super.key, this.onProfileTap});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  // Mocking the locked state for demonstration
  bool isLocked = true;

  final List<Map<String, dynamic>> categories = [
    {'name': 'SSC CGL/CHSL', 'logo': 'assets/icons/ssc_logo.png', 'isPopular': true, 'tests': '150+ Tests'},
    {'name': 'Railways NTPC', 'logo': 'assets/icons/railways_logo.png', 'isNew': true, 'tests': '80+ Tests'},
    {'name': 'IB ACIO', 'logo': 'assets/icons/ib_logo.png', 'tests': '45+ Tests'},
    {'name': 'UPPBPB', 'logo': 'assets/icons/uppbpb_logo.png', 'tests': '30+ Tests'},
    {'name': 'RPF SI/Const', 'logo': 'assets/icons/rpf_logo.png', 'tests': '60+ Tests'},
    {'name': 'Delhi Police', 'logo': 'assets/icons/delhi_police_logo.png', 'isPopular': true, 'tests': '100+ Tests'},
    {'name': 'MP Police', 'logo': 'assets/icons/mp_police_logo.png', 'tests': '50+ Tests'},
    {'name': 'Defence Exams', 'logo': 'assets/icons/defence_logo.png', 'tests': '120+ Tests'},
    {'name': 'Bihar Police', 'logo': 'assets/icons/bihar_police_logo.png', 'tests': '40+ Tests'},
    {'name': 'Rajasthan Exams', 'logo': 'assets/icons/rajasthan_logo.png', 'tests': '90+ Tests'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Test Series',
            onActionPressed: widget.onProfileTap,
          ),
          Expanded(
            child: Stack(
              children: [
                // Background Content (Always visible but dimmed if locked)
                _buildContent(),
                
                if (isLocked) ...[
                  // Interaction Trap: Captures taps on the blurred content
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPaywall = true;
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                  ),
                  
                  // Conditional Paywall Overlay
                  if (_showPaywall) _buildLockOverlay(),
                  
                  // Subtle 'Tap to Unlock' hint if paywall is not yet shown
                  if (!_showPaywall)
                    Positioned(
                      bottom: 40,
                      left: 40,
                      right: 40,
                      child: _buildMiniUnlockHint(),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _showPaywall = false;

  Widget _buildMiniUnlockHint() {
    return AnimatedScaleButton(
      onTap: () => setState(() => _showPaywall = true),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Tap any package to unlock premium',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      physics: isLocked ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: _buildPromoBanner(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  'Exam Packages',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const Spacer(),
                Text(
                  '${categories.length} Categories',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCategoryCard(categories[index]),
              childCount: categories.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Stack(
                    children: [
                      _buildPremiumCard(),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 28),
                          onPressed: () => setState(() => _showPaywall = false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: AppTheme.primary, size: 50),
          ),
          const SizedBox(height: 24),
          const Text(
            'Unlock Premium',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'Join 50,000+ students and get unlimited access to all test series.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildBenefitItem(Icons.check_circle_outline_rounded, '1,000+ Full Mock Tests'),
          _buildBenefitItem(Icons.check_circle_outline_rounded, 'All India Ranking & Analysis'),
          _buildBenefitItem(Icons.check_circle_outline_rounded, 'Detailed Solutions in Hindi/Eng'),
          _buildBenefitItem(Icons.check_circle_outline_rounded, 'Topic-wise Practice Sets'),
          const SizedBox(height: 40),
          AnimatedScaleButton(
            onTap: () {
              // Action to trigger payment
            },
            child: Container(
              height: 64,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'UNLOCK ALL NOW',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Starting from just ₹99/month',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PREMIUM ACCESS',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Master Your Exams',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipOval(
                  child: Image.asset(
                    category['logo']!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.school_rounded, color: Colors.grey.shade300, size: 40),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name']!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category['tests']!,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
