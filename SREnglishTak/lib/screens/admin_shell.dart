import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/stats.dart';
import '../models/book.dart';
import '../models/quiz.dart';
import '../models/admin_user.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import 'admin_panel.dart';
import 'admin_vocabulary_screen.dart';
import 'admin_tips_screen.dart';
import 'admin_grammar_screen.dart';
import 'admin_cbse_screen.dart';
import 'package:intl/intl.dart';
import 'admin_user_progress_screen.dart';
import 'admin_challenges_tab.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  void _setIndex(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: PremiumBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: _buildPage(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildGlassBottomNav(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final title = _index == 0
        ? 'Dashboard'
        : _index == 1
            ? 'Library'
            : _index == 2
                ? 'Quiz Studio'
                : _index == 3
                    ? 'Users'
                    : 'Challenges';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Center',
                    style: TextStyle(
                      color: AppTheme.primary.withOpacity(0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : AppTheme.backgroundDark,
                          height: 1.1,
                        ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => _logout(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.black.withOpacity(0.6) 
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(0, Icons.dashboard_rounded, 'Home'),
              _navItem(1, Icons.library_books_rounded, 'Books'),
              _navItem(2, Icons.quiz_rounded, 'Quizzes'),
              _navItem(3, Icons.people_alt_rounded, 'Users'),
              _navItem(4, Icons.emoji_events_rounded, 'Arenas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label) {
    bool isSelected = _index == idx;
    final unselectedColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white38 
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _setIndex(idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primary : unselectedColor,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (_index == 0) return AdminOverviewPage(onNavigate: _setIndex, key: const ValueKey('overview'));
    if (_index == 1) return const AdminPanel(embedInShell: true, initialTabIndex: 0, key: ValueKey('books'));
    if (_index == 2) return const AdminPanel(embedInShell: true, initialTabIndex: 1, key: ValueKey('quiz'));
    if (_index == 3) return const AdminUsersPage(key: ValueKey('users'));
    if (_index == 4) return const AdminChallengesTab(key: ValueKey('challenges'));
    return const SizedBox.shrink();
  }
}

class AdminOverviewPage extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const AdminOverviewPage({super.key, required this.onNavigate});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  late Future<AdminStats> _statsFuture;
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _statsFuture = ApiService.getAdminStats();
      _booksFuture = ApiService.getAdminBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildActivitySnapshot(),
          const SizedBox(height: 24),
          _buildQuickActionsTitle(),
          const SizedBox(height: 12),
          _buildQuickActionsRow(),
          const SizedBox(height: 24),
          _buildRecentBooks(),
        ],
      ),
    );
  }

  

  Widget _buildStatsGrid() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        final stats = snapshot.data!;
        return Row(
          children: [
            Expanded(child: _statCard('Books', stats.totalBooks.toString(), Icons.library_books_rounded, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Users', stats.totalUsers.toString(), Icons.group_rounded, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Quizzes', stats.totalQuizzes.toString(), Icons.quiz_rounded, Colors.orange)),
          ],
        );
      },
    );
  }

  Widget _buildActivitySnapshot() {
    return FutureBuilder<AdminStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final stats = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACTIVITY SNAPSHOT',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniMetricCard(
                    'Minutes Today',
                    stats.readingMinutesToday.toString(),
                    Icons.timer_outlined,
                    Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniMetricCard(
                    'Readers 7d',
                    stats.activeReaders7d.toString(),
                    Icons.local_fire_department_outlined,
                    Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniMetricCard(
                    'Sessions',
                    stats.totalReadingSessions.toString(),
                    Icons.auto_stories_outlined,
                    Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _miniMetricCard(
                    'Completed Books',
                    stats.completedBooks.toString(),
                    Icons.task_alt_outlined,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  Widget _miniMetricCard(String title, String value, IconData icon, Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsTitle() {
    return const Text(
      'QUICK ACTIONS',
      style: TextStyle(
        color: AppTheme.primary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _actionBtn(Icons.upload_file_rounded, 'Upload\nManuscript', () => widget.onNavigate(1))),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn(Icons.add_task_rounded, 'Create\nQuiz', () => widget.onNavigate(2))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _actionBtn(Icons.translate_rounded, 'Manage\nVocabulary', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVocabularyScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn(Icons.tips_and_updates_rounded, 'Manage\nDaily Tips', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminTipsScreen()));
            })),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _actionBtn(Icons.history_edu_rounded, 'Manage\nGrammar', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminGrammarScreen()));
            })),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn(Icons.school_rounded, 'Manage\nCBSE Hub', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCbseScreen()));
            })),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBooks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ARCHIVES',
          style: TextStyle(
            color: AppTheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Book>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            final books = snapshot.data!;
            if (books.isEmpty) return const Text('No recent books found.', style: TextStyle(color: Colors.grey));
            return Column(
              children: books.take(4).map((book) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(book.coverUrl ?? 'https://via.placeholder.com/60x80'),
                              fit: BoxFit.cover,
                              onError:(e, s) {},
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.category,
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: book.isVisible ? AppTheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            book.isVisible ? 'LIVE' : 'HIDDEN',
                            style: TextStyle(
                              color: book.isVisible ? AppTheme.primary : Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  late Future<List<AdminUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAdminUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = ApiService.getAdminUsers();
    });
  }

  void _showUserProgress(AdminUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserProgressScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        children: [
          const Text(
            'USER DIRECTORY',
            style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<AdminUser>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final users = snapshot.data!;
              return Column(
                children: users.map((user) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showUserProgress(user),
                      borderRadius: BorderRadius.circular(20),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: user.role == 'admin' ? AppTheme.primary : Colors.grey.shade300,
                              child: Text(
                                (user.fullName ?? user.email ?? 'U').substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          user.fullName ?? 'Unnamed User',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (user.className != null && user.className!.trim().isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                                          ),
                                          child: Text(
                                            user.className!,
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.email ?? 'No email',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (user.learningGoal != null && user.learningGoal!.trim().isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.teal.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.teal.withOpacity(0.15)),
                                          ),
                                          child: Text(
                                            user.learningGoal!,
                                            style: const TextStyle(
                                              color: Colors.teal,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (user.role == 'admin') ...[
                              const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 16),
                              const SizedBox(width: 4),
                              const Text('ADMIN', style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                            ] else ...[
                               const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UserProgressDetailDialog extends StatefulWidget {
  final AdminUser user;
  const UserProgressDetailDialog({super.key, required this.user});

  @override
  State<UserProgressDetailDialog> createState() => _UserProgressDetailDialogState();
}

class _UserProgressDetailDialogState extends State<UserProgressDetailDialog> {
  late Future<Map<String, dynamic>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = ApiService.getAdminUserProgress(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassPanel(
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _progressFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text('No progress data found.'));
                    }

                    final data = snapshot.data!;
                    return ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      children: [
                        _buildStatsRow(data),
                        const SizedBox(height: 24),
                        _buildSectionTitle('BOOK SHELF'),
                        const SizedBox(height: 12),
                        _buildBookList(data['book_progress']),
                        const SizedBox(height: 24),
                        _buildSectionTitle('RECENT TESTS'),
                        const SizedBox(height: 12),
                        _buildQuizList(data['quiz_results']),
                      ],
                    );
                  },
                ),
              ),
              _buildCloseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primary,
            child: Text(
              (widget.user.fullName ?? widget.user.email ?? 'U').substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName ?? 'Student',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  widget.user.email ?? '',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
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
            '${data['total_reading_minutes']} min',
            Icons.access_time_filled_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statBox(
            'Active Days',
            '${data['active_reading_days']} days',
            Icons.calendar_today_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.primary,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildBookList(List<dynamic> progress) {
    if (progress.isEmpty) return const Text('No books started yet.', style: TextStyle(color: Colors.grey, fontSize: 13));
    return Column(
      children: progress.map((p) {
        final book = p['books'];
        final percent = (p['progress_percent'] ?? 0).toDouble();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book['cover_url'] ?? 'https://via.placeholder.com/40x60',
                  width: 40,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey, width: 40, height: 56),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book['title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${percent.toInt()}% complete', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuizList(List<dynamic> results) {
    if (results.isEmpty) return const Text('No quizzes taken yet.', style: TextStyle(color: Colors.grey, fontSize: 13));
    return Column(
      children: results.map((r) {
        final quiz = r['quizzes'];
        final date = DateTime.parse(r['completed_at']);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quiz['title'] ?? 'Quiz', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(DateFormat('MMM d, yyyy').format(date), style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${r['score']}',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('Close Details', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
