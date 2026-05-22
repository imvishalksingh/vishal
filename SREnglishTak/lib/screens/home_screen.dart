import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/xp_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/springy_scale_button.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
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

  const HomeScreen({
    super.key,
    this.onLibraryTap,
    this.onTestSeriesTap,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<UserDataProvider>().loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            DashboardHeader(
              title: 'Dashboard',
              onActionPressed: widget.onProfileTap,
              isDashboard: true,
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Stats Row ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _StatsRow(isDark: isDark),
                    ),
                  ),

                  // ── Live Workshops ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                      child: _SectionLabel(
                        label: 'Live Workshops',
                        onSeeAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveWorkshopsScreen(
                              onProfileTap: widget.onProfileTap,
                            ),
                          ),
                        ),
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _WorkshopCarousel(
                      onProfileTap: widget.onProfileTap,
                      isDark: isDark,
                    ),
                  ),

                  // ── Explore Modules ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                      child: _SectionLabel(
                        label: 'Explore Modules',
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
                    sliver: _ModuleList(
                      isDark: isDark,
                      onLibraryTap: widget.onLibraryTap,
                      onTestSeriesTap: widget.onTestSeriesTap,
                      onProfileTap: widget.onProfileTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row — Streak · XP · Level
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark;
  const _StatsRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final xpProvider = context.watch<XpProvider>();
    final userData = context.watch<UserDataProvider>();
    final xp = xpProvider.totalXp;
    final streak = userData.achievements?.summary.currentStreak ?? 0;
    final level = xpProvider.level + 1;

    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: 'Day Streak',
            color: AppTheme.amber,
            isDark: isDark,
          ),
          _VerticalDivider(isDark: isDark),
          _StatChip(
            icon: Icons.diamond_rounded,
            value: '$xp',
            label: 'Total XP',
            color: AppTheme.primary,
            isDark: isDark,
          ),
          _VerticalDivider(isDark: isDark),
          _StatChip(
            icon: Icons.military_tech_rounded,
            value: 'Lv. $level',
            label: 'Your Level',
            color: AppTheme.accent2,
            isDark: isDark,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.12, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final bool isDark;
  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final VoidCallback? onSeeAll;
  final bool isDark;

  const _SectionLabel({required this.label, this.onSeeAll, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all →',
              style: GoogleFonts.inter(
                color: AppTheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Workshop Carousel
// ─────────────────────────────────────────────────────────────────────────────
class _WorkshopCarousel extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final bool isDark;

  const _WorkshopCarousel({required this.onProfileTap, required this.isDark});

  @override
  State<_WorkshopCarousel> createState() => _WorkshopCarouselState();
}

class _WorkshopCarouselState extends State<_WorkshopCarousel> {
  final PageController _pc = PageController(viewportFraction: 0.88);
  int _page = 0;

  final List<Map<String, dynamic>> _workshops = const [
    {
      'title': 'English Grammar\nMasterclass',
      'instructor': 'Dr. Sharma',
      'time': 'LIVE NOW',
      'isLive': true,
      'accent': Color(0xFF6366F1),
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Vocabulary\nBlueprint',
      'instructor': 'Dr. Sharma',
      'time': 'TODAY · 6:00 PM',
      'isLive': false,
      'accent': Color(0xFFF59E0B),
      'icon': Icons.spellcheck_rounded,
    },
    {
      'title': 'Spoken English\nSecrets',
      'instructor': 'Dr. Sharma',
      'time': 'TOMORROW · 4:00 PM',
      'isLive': false,
      'accent': Color(0xFF10B981),
      'icon': Icons.record_voice_over_rounded,
    },
  ];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pc,
            itemCount: _workshops.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (ctx, i) {
              final ws = _workshops[i];
              final accent = ws['accent'] as Color;
              final isLive = ws['isLive'] as bool;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: SpringyScaleButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComingSoonScreen(
                        title: (ws['title'] as String).replaceAll('\n', ' '),
                        onProfileTap: widget.onProfileTap,
                      ),
                    ),
                  ),
                  child: GlassPanel(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            accent.withValues(alpha: widget.isDark ? 0.18 : 0.08),
                            accent.withValues(alpha: 0.01),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isLive
                                          ? AppTheme.accent3.withValues(alpha: 0.12)
                                          : accent.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isLive
                                            ? AppTheme.accent3.withValues(alpha: 0.30)
                                            : accent.withValues(alpha: 0.20),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isLive) ...[
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.accent3,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                        Text(
                                          ws['time'] as String,
                                          style: GoogleFonts.inter(
                                            color: isLive
                                                ? AppTheme.accent3
                                                : accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    ws['title'] as String,
                                    style: GoogleFonts.outfit(
                                      color: widget.isDark
                                          ? Colors.white
                                          : AppTheme.textDark,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'with ${ws['instructor']}',
                                    style: GoogleFonts.inter(
                                      color: widget.isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.20),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                ws['icon'] as IconData,
                                color: accent,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_workshops.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primary
                    : (widget.isDark
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.10, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Module List (replaces cramped 2-col grid)
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleList extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onLibraryTap;
  final VoidCallback? onTestSeriesTap;
  final VoidCallback? onProfileTap;

  const _ModuleList({
    required this.isDark,
    this.onLibraryTap,
    this.onTestSeriesTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final modules = _buildModules(context);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: modules[i]
              .animate()
              .fadeIn(delay: (80 + i * 55).ms, duration: 350.ms)
              .slideY(begin: 0.08, duration: 350.ms, curve: Curves.easeOutCubic),
        ),
        childCount: modules.length,
      ),
    );
  }

  List<Widget> _buildModules(BuildContext context) {
    return [
      _ModuleCard(
        title: 'Free Test Package',
        description: 'Practice papers, mock tests and previous year questions',
        icon: Icons.assignment_turned_in_outlined,
        color: AppTheme.primary,
        isDark: isDark,
        onTap: () => onTestSeriesTap?.call(),
      ),
      _ModuleCard(
        title: 'Grammar Hub',
        description: 'Master tenses, articles, prepositions and sentence structure',
        icon: Icons.translate_rounded,
        color: AppTheme.accent2,
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GrammarHubScreen(onProfileTap: onProfileTap),
          ),
        ),
      ),
      _ModuleCard(
        title: 'Vocabulary Builder',
        description: 'Expand your word power with meanings, examples and usage',
        icon: Icons.spellcheck_rounded,
        color: AppTheme.accent3,
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VocabularyScreen(onProfileTap: onProfileTap),
          ),
        ),
      ),
      _ModuleCard(
        title: 'CBSE Board Prep',
        description: 'Chapter-wise study material and resources for board exams',
        icon: Icons.school_outlined,
        color: const Color(0xFF3B82F6),
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CbseDashboardScreen(onProfileTap: onProfileTap),
          ),
        ),
      ),
      _ModuleCard(
        title: 'Daily Quiz',
        description: 'Test your knowledge with fresh questions every day',
        icon: Icons.lightbulb_outline_rounded,
        color: const Color(0xFF8B5CF6),
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizView()),
        ),
      ),
      _ModuleCard(
        title: 'Daily Tips',
        description: 'Quick grammar and vocabulary tips to read each morning',
        icon: Icons.tips_and_updates_outlined,
        color: AppTheme.amber,
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DailyTipsScreen(onProfileTap: onProfileTap),
          ),
        ),
      ),
      _ModuleCard(
        title: 'Free E-Books',
        description: 'Curated English books, novels and reading materials',
        icon: Icons.auto_stories_outlined,
        color: const Color(0xFF6B7280),
        isDark: isDark,
        onTap: () => onLibraryTap?.call(),
      ),
      _ModuleCard(
        title: 'Previous Papers',
        description: 'Solved question papers from past board examinations',
        icon: Icons.description_outlined,
        color: const Color(0xFF374151),
        isDark: isDark,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComingSoonScreen(
              title: 'Previous Papers',
              onProfileTap: onProfileTap,
            ),
          ),
        ),
      ),
    ];
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpringyScaleButton(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
