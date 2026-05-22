import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../models/bookmark.dart';
import '../models/reader_note.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PdfReaderScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String url;

  const PdfReaderScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.url,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  DateTime? _sessionStartedAt;
  String? _sessionId;
  int _currentPage = 1;
  int _startPage = 1;
  int _pageCount = 0;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    _sessionStartedAt = DateTime.now();
    try {
      final session = await ApiService.startReadingSession(
        widget.bookId,
        startPage: _startPage,
        deviceType: 'mobile',
        source: 'pdf_reader',
      );
      _sessionId = session.id;
    } catch (_) {
      // Keep reading even if analytics fails.
    }
  }

  Future<void> _finishSession() async {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;

    final secondsSpent = DateTime.now().difference(startedAt).inSeconds;
    int minutesSpent = (secondsSpent / 60).round();
    if (secondsSpent > 5 && minutesSpent == 0) {
      minutesSpent = 1;
    }
    minutesSpent = minutesSpent.clamp(0, 24 * 60);

    final pagesRead = (_currentPage - _startPage).abs();
    final progressPercent = _pageCount > 0 ? (_currentPage / _pageCount) * 100 : null;
    final isCompleted = _pageCount > 0 && _currentPage >= _pageCount;

    try {
      await ApiService.updateProgress(
        widget.bookId,
        _currentPage,
        progressPercent: progressPercent,
        isCompleted: isCompleted,
        totalMinutesRead: minutesSpent,
        lastPosition: 'page:$_currentPage',
      );
      if (_sessionId != null) {
        await ApiService.finishReadingSession(
          _sessionId!,
          endPage: _currentPage,
          minutesSpent: minutesSpent,
          pagesRead: pagesRead,
          isCompleted: isCompleted,
        );
      }
    } catch (_) {
      // Do not block closing the reader on tracking failures.
    }
  }

  Future<void> _addBookmark() async {
    try {
      await ApiService.createBookmark(
        widget.bookId,
        page: _currentPage,
        position: 'page:$_currentPage',
        label: 'Page $_currentPage',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bookmark saved for page $_currentPage')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save bookmark: $e')),
      );
    }
  }

  Future<void> _showAddNoteDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note - Page $_currentPage'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a note about this page',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await ApiService.createNote(
        widget.bookId,
        result,
        page: _currentPage,
        position: 'page:$_currentPage',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save note: $e')),
      );
    }
  }

  Future<void> _showSavedItems() async {
    final bookmarks = await ApiService.getBookmarks(bookId: widget.bookId);
    final notes = await ApiService.getNotes(bookId: widget.bookId);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Bookmarks'),
                    Tab(text: 'Notes'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBookmarksList(bookmarks),
                      _buildNotesList(notes),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarksList(List<Bookmark> bookmarks) {
    if (bookmarks.isEmpty) {
      return const Center(child: Text('No bookmarks yet'));
    }
    return ListView.builder(
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return ListTile(
          leading: const Icon(Icons.bookmark, color: AppTheme.primary),
          title: Text(bookmark.label ?? 'Saved page ${bookmark.page}'),
          subtitle: Text(bookmark.position ?? 'Page ${bookmark.page}'),
        );
      },
    );
  }

  Widget _buildNotesList(List<ReaderNote> notes) {
    if (notes.isEmpty) {
      return const Center(child: Text('No notes yet'));
    }
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          leading: const Icon(Icons.sticky_note_2_outlined, color: AppTheme.primary),
          title: Text(note.noteText, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(note.position ?? 'Page ${note.page}'),
        );
      },
    );
  }

  @override
  void dispose() {
    _finishSession();
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _addBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _showAddNoteDialog,
          ),
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: _showSavedItems,
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.url,
        controller: _pdfController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          _pageCount = details.document.pages.count;
        },
        onPageChanged: (PdfPageChangedDetails details) {
          _currentPage = details.newPageNumber;
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load PDF: ${details.description}')),
          );
        },
      ),
    );
  }
}
