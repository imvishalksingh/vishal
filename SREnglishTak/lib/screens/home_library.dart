import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_scale_button.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/glass_panel.dart';
import '../widgets/premium_background.dart';
import '../widgets/shimmer_loader.dart';
import 'epub_reader_screen.dart';
import 'pdf_reader_screen.dart';

import '../widgets/dashboard_header.dart';

class HomeLibrary extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeLibrary({super.key, this.onProfileTap});

  @override
  State<HomeLibrary> createState() => _HomeLibraryState();
}

class _HomeLibraryState extends State<HomeLibrary> {
  late Future<List<Book>> _booksFuture;
  late Future<List<UserProgress>> _progressFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _booksFuture = ApiService.getBooks();
      _progressFuture = AuthService.isLoggedIn
          ? ApiService.getProgress()
          : Future.value([]);
    });
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_searchQuery.isEmpty) _buildContinueReadingSection(),
                  _buildLibraryGridSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DashboardHeader(
      title: 'Free Content',
      onActionPressed: widget.onProfileTap,
    );
  }

  Widget _buildSearchBarWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search books, authors...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6200EE)),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    return FutureBuilder<List<UserProgress>>(
      future: _progressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildContinueReading(context, snapshot.data!);
      },
    );
  }

  Widget _buildContinueReading(
    BuildContext context,
    List<UserProgress> progressList,
  ) {
    // Sort by last read date if available
    progressList.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_stories_rounded,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 340,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: progressList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final progress = progressList[index];
                return FutureBuilder<List<Book>>(
                  future: _booksFuture,
                  builder: (context, bookListSnapshot) {
                    if (!bookListSnapshot.hasData) return const SizedBox(width: 170);
                    
                    final book = bookListSnapshot.data!.firstWhere(
                      (b) => b.id == progress.bookId,
                      orElse: () => Book(
                        id: '?', 
                        title: 'Unknown', 
                        author: '', 
                        description: '', 
                        category: '', 
                        formatType: 'pdf', 
                        isVisible: false
                      ),
                    );
                    
                    if (book.id == '?') return const SizedBox.shrink();

                    return AnimatedScaleButton(
                      onTap: () => _openBook(context, book),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(12),
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 170,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cover with Progress Overlaid
                              Stack(
                                children: [
                                  Container(
                                    width: 170,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          book.coverUrl ?? 'https://via.placeholder.com/170x220?text=No+Cover',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              // FIX: Using actual progressPercent from model
                                              value: progress.progressPercent / 100,
                                              backgroundColor: Colors.white.withOpacity(0.2),
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                              minHeight: 4,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${progress.progressPercent.toInt()}% Complete',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                book.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryGridSection() {
    return FutureBuilder<List<Book>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ShimmerLoader(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                );
              },
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(child: Text('No books found.')),
          );
        }

        final filteredBooks = snapshot.data!.where((b) {
          return b.title.toLowerCase().contains(_searchQuery) || 
                 b.author.toLowerCase().contains(_searchQuery) ||
                 b.category.toLowerCase().contains(_searchQuery);
        }).toList();

        if (filteredBooks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(64.0),
            child: Center(child: Text('No matches found for your search.')),
          );
        }

        return _buildLibraryGrid(context, filteredBooks);
      },
    );
  }

  Widget _buildLibraryGrid(BuildContext context, List<Book> books) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    _searchQuery.isEmpty ? 'All Books & PDFs' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return AnimatedScaleButton(
                onTap: () => _openBook(context, book),
                child: GlassPanel(
                  padding: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    book.coverUrl ?? 'https://via.placeholder.com/128x192?text=No+Cover',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: book.formatType.toLowerCase() == 'pdf'
                                      ? Colors.red.shade900.withOpacity(0.9)
                                      : AppTheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  book.formatType.toUpperCase(),
                                  style: TextStyle(
                                    color: book.formatType.toLowerCase() == 'pdf' ? Colors.white : AppTheme.backgroundDark,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        book.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _openBook(context, book),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.backgroundDark,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            book.formatType.toLowerCase() == 'pdf' ? 'Open PDF' : 'Read Now',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openBook(BuildContext context, Book book) {
    if (book.formatType.toLowerCase() == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfReaderScreen(
            bookId: book.id,
            title: book.title,
            url: book.fileUrl ?? '',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpubReaderScreen(
            bookId: book.id,
            title: book.title,
            url: book.fileUrl ?? '',
          ),
        ),
      );
    }
  }
}
