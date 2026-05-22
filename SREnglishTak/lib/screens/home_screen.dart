import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/dashboard_header.dart';
import 'quiz_view.dart';
import 'cbse_dashboard_screen.dart';
import 'grammar_hub_screen.dart';
import 'vocabulary_screen.dart';
import 'daily_tips_screen.dart';
import 'coming_soon_screen.dart';
import 'arena_screen.dart';
import 'live_workshops_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onLibraryTap;
  final VoidCallback? onTestSeriesTap;
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onLibraryTap, this.onTestSeriesTap, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<UserDataProvider>().loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionHeader('Live Workshops', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveWorkshopsScreen(onProfileTap: widget.onProfileTap),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    _buildLiveCarousel(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Explore Modules', null),
                    const SizedBox(height: 16),
                    _buildFeatureGrid(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontSize: 20,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All', style: TextStyle(color: Color(0xFF6200EE), fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildLiveCarousel() {
    final List<Map<String, dynamic>> workshops = [
      {
        'title': 'English Grammar Masterclass',
        'instructor': 'Dr. Sharma',
        'time': 'LIVE NOW',
        'colors': [const Color(0xFF6366F1), const Color(0xFFA855F7)],
        'isLive': true,
      },
      {
        'title': 'Vocabulary Blueprint',
        'instructor': 'Dr. Sharma',
        'time': 'TODAY, 6:00 PM',
        'colors': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
        'isLive': false,
      },
      {
        'title': 'Spoken English Secrets',
        'instructor': 'Dr. Sharma',
        'time': 'TOMORROW, 4:00 PM',
        'colors': [const Color(0xFF10B981), const Color(0xFF3B82F6)],
        'isLive': false,
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: workshops.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final ws = workshops[index];
          final colors = ws['colors'] as List<Color>;
          final isLive = ws['isLive'] as bool;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ComingSoonScreen(
                    title: ws['title'] as String,
                    onProfileTap: widget.onProfileTap,
                  ),
                ),
              );
            },
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(Icons.bolt, size: 120, color: Colors.white.withOpacity(0.2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: isLive ? Colors.red : Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLive ? 'LIVE NOW' : (ws['time'] as String),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ws['title'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'with ${ws['instructor']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DashboardHeader(
      title: 'Home',
      onActionPressed: widget.onProfileTap,
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Column(
      children: [
        _buildFeatureRow(context, [
          _FeatureData(
            'Free Test\nPackage',
            Icons.assignment_turned_in_rounded,
            [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
            () => widget.onTestSeriesTap?.call(),
          ),
          _FeatureData(
            'Practice\nArena',
            Icons.sports_esports_rounded,
            [const Color(0xFF0F172A), const Color(0xFF334155)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ArenaScreen())),
          ),
        ]),
        const SizedBox(height: 16),
        _buildFeatureRow(context, [
          _FeatureData(
            'CBSE\nBoard',
            Icons.school_rounded,
            [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => CbseDashboardScreen(onProfileTap: widget.onProfileTap))),
          ),
          _FeatureData(
            'Daily\nQuiz',
            Icons.lightbulb_rounded,
            [const Color(0xFF4C1D95), const Color(0xFF8B5CF6)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizView())),
          ),
        ]),
        const SizedBox(height: 16),
        _buildFeatureRow(context, [
          _FeatureData(
            'Grammar\nHub',
            Icons.translate_rounded,
            [const Color(0xFF064E3B), const Color(0xFF10B981)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => GrammarHubScreen(onProfileTap: widget.onProfileTap))),
          ),
          _FeatureData(
            'Vocabulary\nBuilder',
            Icons.spellcheck_rounded,
            [const Color(0xFF7F1D1D), const Color(0xFFEF4444)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => VocabularyScreen(onProfileTap: widget.onProfileTap))),
          ),
        ]),
        const SizedBox(height: 16),
        _buildFeatureRow(context, [
          _FeatureData(
            'Daily\nTips',
            Icons.tips_and_updates_rounded,
            [const Color(0xFF78350F), const Color(0xFFF59E0B)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => DailyTipsScreen(onProfileTap: widget.onProfileTap))),
          ),
          _FeatureData(
            'Free\nE-Books',
            Icons.auto_stories_rounded,
            [const Color(0xFF374151), const Color(0xFF6B7280)],
            () => widget.onLibraryTap?.call(),
          ),
        ]),
        const SizedBox(height: 16),
        _buildFeatureRow(context, [
          _FeatureData(
            'Previous\nPapers',
            Icons.description_rounded,
            [const Color(0xFF1F2937), const Color(0xFF4B5563)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: 'Previous Papers', onProfileTap: widget.onProfileTap))),
          ),
          _FeatureData(
            'Community\nGroups',
            Icons.groups_rounded,
            [const Color(0xFF4B2C20), const Color(0xFF8D6E63)],
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => ComingSoonScreen(title: 'Community', onProfileTap: widget.onProfileTap))),
          ),
        ]),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, List<_FeatureData> features) {
    return Row(
      children: features.map((f) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: features.indexOf(f) == features.length - 1 ? 0 : 16),
          child: _buildFeatureCard(context, f.title, f.icon, f.gradientColors, f.onTap),
        ),
      )).toList(),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    VoidCallback onTap,
  ) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[1].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  icon,
                  size: 110,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: 0.5,
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
}

class _FeatureData {
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  _FeatureData(this.title, this.icon, this.gradientColors, this.onTap);
}
