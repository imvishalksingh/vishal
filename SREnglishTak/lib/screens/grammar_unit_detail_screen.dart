import 'package:flutter/material.dart';
import '../models/grammar_unit.dart';
import '../models/grammar_lesson.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/premium_background.dart';

class GrammarUnitDetailScreen extends StatefulWidget {
  final GrammarUnit unit;
  final List<String> completedLessonIds;

  const GrammarUnitDetailScreen({
    super.key,
    required this.unit,
    required this.completedLessonIds,
  });

  @override
  State<GrammarUnitDetailScreen> createState() => _GrammarUnitDetailScreenState();
}

class _GrammarUnitDetailScreenState extends State<GrammarUnitDetailScreen> {
  late Future<List<GrammarLesson>> _lessonsFuture;
  late List<String> _localCompletedIds;

  @override
  void initState() {
    super.initState();
    _localCompletedIds = List.from(widget.completedLessonIds);
    _refresh();
  }

  void _refresh() {
    setState(() {
      _lessonsFuture = ApiService.getGrammarLessons(widget.unit.id);
    });
  }

  Future<void> _markComplete(GrammarLesson lesson) async {
    try {
      await ApiService.markGrammarLessonCompleted(lesson.id);
      setState(() {
        if (!_localCompletedIds.contains(lesson.id)) {
          _localCompletedIds.add(lesson.id);
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson marked as complete!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.unit.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: FutureBuilder<List<GrammarLesson>>(
              future: _lessonsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load lessons.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final lessons = snapshot.data ?? [];

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.unit.description != null && widget.unit.description!.isNotEmpty)
                              Text(
                                widget.unit.description!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                ),
                              ),
                            const SizedBox(height: 24),
                            Text(
                              'Lessons in this Unit',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    if (lessons.isEmpty)
                      const SliverFillRemaining(
                        child: Center(child: Text('No lessons available in this unit.')),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final lesson = lessons[index];
                              final isCompleted = _localCompletedIds.contains(lesson.id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildLessonCard(lesson, isCompleted),
                              );
                            },
                            childCount: lessons.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(GrammarLesson lesson, bool isCompleted) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          _showLessonContent(lesson, isCompleted);
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check_circle_rounded : Icons.play_lesson_rounded,
                color: isCompleted ? Colors.green : AppTheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson ${lesson.lessonOrder}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  void _showLessonContent(GrammarLesson lesson, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                lesson.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Text(
                    lesson.contentData ?? 'No content available.',
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!isCompleted) {
                      _markComplete(lesson);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.green : AppTheme.primary,
                  ),
                  child: Text(isCompleted ? 'Completed' : 'Mark Complete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
