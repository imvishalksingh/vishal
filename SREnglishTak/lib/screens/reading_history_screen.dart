import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<UserDataProvider>();
    final progressList = List.from(dataProvider.progress); // Create mutable copy
    final booksList = dataProvider.books;

    // Sort heavily by lastReadAt descending
    progressList.sort((a, b) {
      if (a.lastReadAt == null || b.lastReadAt == null) return 0;
      return b.lastReadAt!.compareTo(a.lastReadAt!);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: dataProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (progressList.isEmpty
                        ? const Center(
                            child: Text(
                              'No reading history found.\nStart reading to build your streak!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, height: 1.5),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: progressList.length,
                            itemBuilder: (context, index) {
                              final progress = progressList[index];
                              final book = booksList.firstWhere(
                                (b) => b.id == progress.bookId,
                                orElse: () => Book(
                                  id: '',
                                  title: 'Unknown Manuscript',
                                  author: '',
                                  description: '',
                                  category: '',
                                  formatType: '',
                                  isVisible: true,
                                ),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassPanel(
                                  padding: const EdgeInsets.all(12),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.grey.shade800,
                                          image: book.coverUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(book.coverUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: book.coverUrl == null
                                            ? const Icon(Icons.book, color: Colors.grey)
                                            : null,
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
                                              'Page ${progress.currentPage} • ${progress.progressPercent.toStringAsFixed(0)}% Read',
                                              style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 8),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: progress.progressPercent / 100,
                                                backgroundColor: AppTheme.primary.withOpacity(0.1),
                                                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                                                minHeight: 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            'Reading History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}
