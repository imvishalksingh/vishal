import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/vocabulary.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/glass_panel.dart';

class VocabularyScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const VocabularyScreen({super.key, this.onProfileTap});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  late Future<List<Vocabulary>> _vocabFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _vocabFuture = ApiService.getVocabularyList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: Column(
          children: [
            DashboardHeader(
              title: 'Vocabulary',
              isDashboard: false,
              onActionPressed: widget.onProfileTap,
            ),
            _buildGlassSearchBar(),
            Expanded(
              child: FutureBuilder<List<Vocabulary>>(
                future: _vocabFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final allWords = snapshot.data!;
                  final filtered = _searchQuery.isEmpty
                      ? allWords
                      : allWords
                          .where((v) =>
                              v.word
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              v.meaning
                                  .toLowerCase()
                                  .contains(_searchQuery) ||
                              (v.category
                                      ?.toLowerCase()
                                      .contains(_searchQuery) ??
                                  false))
                          .toList();

                  if (filtered.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refresh(),
                    color: AppTheme.primary,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _VocabularyCard(vocab: filtered[index])
                            .animate()
                            .fadeIn(
                              delay: (index * 50).ms,
                              duration: 300.ms,
                            )
                            .slideY(
                              begin: 0.06,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase().trim());
              },
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search words or meanings...',
                hintStyle: GoogleFonts.inter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.35)
                      : AppTheme.textMutedDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.50)
                              : AppTheme.textMutedDark,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: -0.04, duration: 350.ms, curve: Curves.easeOut);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading vocabulary...',
            style: GoogleFonts.inter(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.50)
                  : AppTheme.textMutedDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent3.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.accent3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load words',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.45)
                    : AppTheme.textMutedDark,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _refresh,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF818CF8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withValues(alpha: 0.10),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 44,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No words yet',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vocabulary content will be added shortly.',
            style: GoogleFonts.inter(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : AppTheme.textMutedDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withValues(alpha: 0.10),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.35)
                  : AppTheme.textMutedDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No results found',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : AppTheme.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No matches for "$_searchQuery"',
            style: GoogleFonts.inter(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : AppTheme.textMutedDark,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VocabularyCard
// ─────────────────────────────────────────────────────────────────────────────

class _VocabularyCard extends StatefulWidget {
  final Vocabulary vocab;
  const _VocabularyCard({required this.vocab});

  @override
  State<_VocabularyCard> createState() => _VocabularyCardState();
}

class _VocabularyCardState extends State<_VocabularyCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasExample = widget.vocab.exampleSentence != null &&
        widget.vocab.exampleSentence!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: _toggle,
        child: GlassPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: word + badge + share ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word title
                  Expanded(
                    child: Text(
                      widget.vocab.word,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ),

                  // Category / part-of-speech badge
                  if (widget.vocab.category != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accent2.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.accent2.withValues(alpha: 0.28),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.vocab.category!.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: AppTheme.accent2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],

                  // Share button (minimum 48×48 touch target)
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Share.share(
                          '📖 Word of the day: ${widget.vocab.word} — ${widget.vocab.meaning}. Learn English with SR English Tak!',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Meaning ───────────────────────────────────────────────────
              Text(
                widget.vocab.meaning,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : AppTheme.textDark,
                ),
              ),

              // ── Animated example sentence ─────────────────────────────────
              if (hasExample)
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: -1,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppTheme.primary.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: const Border(
                            left: BorderSide(
                              color: AppTheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.format_quote_rounded,
                                size: 16,
                                color:
                                    AppTheme.primary.withValues(alpha: 0.80),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.vocab.exampleSentence!,
                                style: GoogleFonts.inter(
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.60)
                                      : AppTheme.textMutedDark,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ── Expand / collapse chevron ─────────────────────────────────
              if (hasExample) ...[
                const SizedBox(height: 10),
                Center(
                  child: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.30)
                          : AppTheme.textMutedDark.withValues(alpha: 0.50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
