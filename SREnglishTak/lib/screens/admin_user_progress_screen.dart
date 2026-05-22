import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/admin_user.dart';
import '../services/api_service.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminUserProgressScreen extends StatefulWidget {
  final AdminUser user;

  const AdminUserProgressScreen({super.key, required this.user});

  @override
  State<AdminUserProgressScreen> createState() =>
      _AdminUserProgressScreenState();
}

class _AdminUserProgressScreenState extends State<AdminUserProgressScreen> {
  late Future<Map<String, dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ApiService.getAdminUserProgress(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        title: const Text(
          'Student Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: PremiumBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _progressFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load progress',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {
                            _progressFuture = ApiService.getAdminUserProgress(
                                widget.user.id);
                          }),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 20),
                  _buildStatsRow(data),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      'READING BOOKSHELF',
                      Icons.menu_book_rounded,
                      Colors.blue,
                      '${(data['book_progress'] as List).length} books'),
                  const SizedBox(height: 12),
                  _buildBookList(data['book_progress'] as List),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                      'QUIZ PERFORMANCE',
                      Icons.quiz_rounded,
                      Colors.orange,
                      '${(data['quiz_results'] as List).length} tests'),
                  const SizedBox(height: 12),
                  _buildQuizList(data['quiz_results'] as List),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (widget.user.fullName ?? widget.user.email ?? 'U')
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
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
                  widget.user.fullName ?? 'Student',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.email ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.user.role == 'admin'
                            ? AppTheme.primary.withOpacity(0.15)
                            : AppTheme.accent2.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.user.role.toUpperCase(),
                        style: TextStyle(
                          color: widget.user.role == 'admin'
                              ? AppTheme.primary
                              : AppTheme.accent2,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (widget.user.className != null && widget.user.className!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.18)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school, size: 10, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              widget.user.className!,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.user.learningGoal != null && widget.user.learningGoal!.trim().isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.teal.withOpacity(0.18)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 10, color: Colors.teal),
                            const SizedBox(width: 4),
                            Text(
                              widget.user.learningGoal!,
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _statBox(
            'Total Time',
            '${data['total_reading_minutes']}',
            'minutes',
            Icons.access_time_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            'Active Days',
            '${data['active_reading_days']}',
            'days',
            Icons.local_fire_department_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            'Books Read',
            '${(data['book_progress'] as List).where((p) => p['is_completed'] == true).length}',
            'completed',
            Icons.task_alt_rounded,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, String unit, IconData icon,
      Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          Text(
            unit,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, Color color, String badge) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badge,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBookList(List<dynamic> progress) {
    if (progress.isEmpty) {
      return _emptyState(
          Icons.menu_book_outlined, 'No books started yet', Colors.blue);
    }
    return Column(
      children: progress.map((p) {
        final book = p['books'] as Map<String, dynamic>?;
        final percent = (p['progress_percent'] ?? 0).toDouble();
        final isCompleted = p['is_completed'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            padding: const EdgeInsets.all(14),
            borderRadius: BorderRadius.circular(18),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    book?['cover_url'] ?? 'https://via.placeholder.com/44x60',
                    width: 44,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 44,
                      height: 60,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.book, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              book?['title'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('DONE',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      if (book?['author'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          book!['author'],
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent / 100,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted ? Colors.green : AppTheme.primary,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${percent.toInt()}%',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuizList(List<dynamic> results) {
    if (results.isEmpty) {
      return _emptyState(
          Icons.quiz_outlined, 'No quizzes taken yet', Colors.orange);
    }

    final totalScore = results.fold<double>(
        0, (sum, r) => sum + ((r['score'] ?? 0) as num).toDouble());
    final avgScore = results.isNotEmpty ? totalScore / results.length : 0;

    return Column(
      children: [
        // Average Score Banner
        GlassPanel(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AVERAGE SCORE',
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.3)),
                  const SizedBox(height: 4),
                  Text(
                    avgScore.toStringAsFixed(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(
                      color: Colors.orange.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${results.length}',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...results.map((r) {
          final quiz = r['quizzes'] as Map<String, dynamic>?;
          final rawDate = r['completed_at'];
          final date = rawDate != null ? DateTime.tryParse(rawDate) : null;
          final score = (r['score'] ?? 0) as num;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz?['title'] ?? 'Quiz',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          date != null
                              ? DateFormat('MMM d, yyyy').format(date)
                              : 'Unknown date',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$score',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _emptyState(IconData icon, String message, Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.5), size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
