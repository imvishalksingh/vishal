import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;

import '../models/bookmark.dart';
import '../models/reader_note.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EpubReaderScreen extends StatefulWidget {
  final String bookId;
  final String title;
  final String url;

  const EpubReaderScreen({
    super.key,
    required this.bookId,
    required this.title,
    required this.url,
  });

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  EpubController? _epubController;
  bool _isLoading = true;
  DateTime? _sessionStartedAt;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _startSession();
    _loadEpub();
  }

  Future<void> _startSession() async {
    _sessionStartedAt = DateTime.now();
    try {
      final session = await ApiService.startReadingSession(
        widget.bookId,
        startPage: 0,
        deviceType: 'mobile',
        source: 'epub_reader',
      );
      _sessionId = session.id;
    } catch (_) {
      // Keep reading even if analytics fails.
    }
  }

  Future<void> _loadEpub() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final bytes = response.bodyBytes;

      _epubController = EpubController(
        document: EpubDocument.openData(bytes),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading eBook: $e')),
        );
      }
    }
  }

  Future<void> _finishSession() async {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return;

    final secondsSpent = DateTime.now().difference(startedAt).inSeconds;
    // Log at least 1 minute if they read for > 5 seconds, otherwise calculate normal minutes.
    int minutesSpent = (secondsSpent / 60).round();
    if (secondsSpent > 5 && minutesSpent == 0) {
      minutesSpent = 1;
    }
    minutesSpent = minutesSpent.clamp(0, 24 * 60);

    try {
      await ApiService.updateProgress(
        widget.bookId,
        0,
        totalMinutesRead: minutesSpent,
        lastPosition: 'epub:last-opened',
      );
      if (_sessionId != null) {
        await ApiService.finishReadingSession(
          _sessionId!,
          endPage: 0,
          minutesSpent: minutesSpent,
          pagesRead: 0,
          isCompleted: false,
        );
      }
    } catch (_) {
      // Keep app responsive even if tracking fails.
    }
  }

  Future<void> _addBookmark() async {
    try {
      await ApiService.createBookmark(
        widget.bookId,
        page: 0,
        position: 'epub:last-opened',
        label: 'EPUB bookmark',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bookmark saved')),
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
        title: const Text('Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a note about this section',
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
        page: 0,
        position: 'epub:last-opened',
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
          title: Text(bookmark.label ?? 'Saved section'),
          subtitle: Text(bookmark.position ?? 'EPUB position'),
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
          subtitle: Text(note.position ?? 'EPUB position'),
        );
      },
    );
  }

  @override
  void dispose() {
    _finishSession();
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _epubController == null
            ? Text(widget.title)
            : EpubViewActualChapter(
                controller: _epubController!,
                builder: (chapterValue) => Text(
                  chapterValue?.chapter?.Title?.trim() ?? widget.title,
                  textAlign: TextAlign.start,
                ),
              ),
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
            icon: const Icon(Icons.more_horiz),
            onPressed: _showSavedItems,
          ),
          Builder(
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Scaffold.of(buttonContext).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: _epubController != null
            ? EpubViewTableOfContents(controller: _epubController!)
            : const Center(child: CircularProgressIndicator()),
      ),
      body: _isLoading || _epubController == null
          ? const Center(child: CircularProgressIndicator())
          : EpubView(
              controller: _epubController!,
            ),
    );
  }
}
