import 'package:flutter/material.dart';
import '../models/grammar_unit.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/premium_background.dart';
import '../widgets/dashboard_header.dart';
import 'grammar_unit_detail_screen.dart';

class GrammarHubScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const GrammarHubScreen({super.key, this.onProfileTap});

  @override
  State<GrammarHubScreen> createState() => _GrammarHubScreenState();
}

class _GrammarHubScreenState extends State<GrammarHubScreen> {
  late Future<List<GrammarUnit>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = ApiService.getGrammarUnits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Grammar Hub',
            onActionPressed: widget.onProfileTap,
          ),
          Expanded(
            child: PremiumBackground(
              child: FutureBuilder<List<GrammarUnit>>(
                future: _unitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final units = snapshot.data ?? [];

                  if (units.isEmpty) {
                    return _buildEmptyState();
                  }

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'CURRICULUM',
                            style: TextStyle(
                              color: AppTheme.primary.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildUnitCard(units[index]),
                            ),
                            childCount: units.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildUnitCard(GrammarUnit unit) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrammarUnitDetailScreen(
                unit: unit,
                completedLessonIds: const [],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    unit.unitOrder.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.description ?? 'Master this grammar module',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Network Error', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() => _unitsFuture = ApiService.getGrammarUnits()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Coming Soon', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          Text('We are preparing the lessons for you.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
