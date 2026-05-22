import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/book.dart';
import '../models/quiz.dart';
import '../models/stats.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../widgets/glass_panel.dart';
import 'create_quiz_screen.dart';

class AdminPanel extends StatefulWidget {
  final bool embedInShell;
  final int initialTabIndex;

  const AdminPanel({
    super.key,
    this.embedInShell = false,
    this.initialTabIndex = 0,
  });

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  late Future<List<Book>> _booksFuture;
  late Future<List<Quiz>> _quizzesFuture;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _fileUrlController = TextEditingController();
  String _selectedFormat = 'pdf';
  String _selectedCategory = 'Classic Literature';
  
  String? _pickedFilePath;
  String? _pickedFileName;
  String? _pickedCoverPath;
  String? _pickedCoverName;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _booksFuture = ApiService.getAdminBooks();
      _quizzesFuture = ApiService.getQuizzes();
    });
  }

  Future<void> _publishBook() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (_pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a book file')));
      return;
    }

    try {
      String fileUrl = "";
      String coverUrl = "";

      if (_pickedFilePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading book file...')));
        fileUrl = await ApiService.uploadFile(_pickedFilePath!);
      } else {
        fileUrl = _fileUrlController.text;
      }
      
      if (_pickedCoverPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading cover image...')));
        coverUrl = await ApiService.uploadFile(_pickedCoverPath!);
      } else {
        coverUrl = _coverUrlController.text;
      }

      final newBook = Book(
        id: '', 
        title: _titleController.text,
        author: _authorController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        formatType: _selectedFormat,
        coverUrl: coverUrl,
        fileUrl: fileUrl,
        isVisible: true,
      );

      await ApiService.createBook(newBook);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book published successfully!')));
      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _coverUrlController.clear();
      _fileUrlController.clear();
      setState(() {
        _pickedFilePath = null;
        _pickedFileName = null;
        _pickedCoverPath = null;
        _pickedCoverName = null;
      });
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickBookFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (result != null) {
      setState(() {
        _pickedFilePath = result.files.single.path;
        _pickedFileName = result.files.single.name;
        if (_pickedFileName!.toLowerCase().endsWith('.pdf')) _selectedFormat = 'pdf';
        if (_pickedFileName!.toLowerCase().endsWith('.epub')) _selectedFormat = 'epub';
      });
    }
  }

  Future<void> _pickCoverImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _pickedCoverPath = result.files.single.path;
        _pickedCoverName = result.files.single.name;
      });
    }
  }

  Future<void> _deleteBook(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this manuscript? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('DELETE FOR ALL', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteBook(id);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting book: $e')));
      }
    }
  }

  Future<void> _toggleBookVisibility(Book book) async {
    try {
      await ApiService.updateBook(book.id, {'is_visible': !book.isVisible});
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(book.isVisible ? 'Book hidden' : 'Book is now live!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _editBook(Book book) {
    _titleController.text = book.title;
    _authorController.text = book.author;
    _descriptionController.text = book.description;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: _authorController, decoration: const InputDecoration(labelText: 'Author')),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.updateBook(book.id, {
                  'title': _titleController.text,
                  'author': _authorController.text,
                  'description': _descriptionController.text,
                });
                if (!mounted) return;
                Navigator.pop(context);
                _refreshData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleQuizVisibility(Quiz quiz) async {
    try {
      await ApiService.updateQuiz(quiz.id, {'is_visible': !quiz.isVisible});
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quiz.isVisible ? 'Quiz hidden' : 'Quiz is now live!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _editQuiz(Quiz quiz) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(existingQuiz: quiz),
      ),
    );
    if (result == true) _refreshData();
  }

  Future<void> _deleteQuiz(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz?'),
        content: const Text('This will remove the quiz sequence for all students.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteQuiz(id);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _navigateToCreateQuiz() async {
    final quizType = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose Quiz Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.menu_book_rounded, color: AppTheme.primary),
              ),
              title: const Text('Book specific', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Questions tied to a manuscript', style: TextStyle(fontSize: 12, color: Colors.grey)),
              onTap: () => Navigator.pop(context, 'book'),
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.public_rounded, color: Colors.orange),
              ),
              title: const Text('General Knowledge', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Standalone exam prep module', style: TextStyle(fontSize: 12, color: Colors.grey)),
              onTap: () => Navigator.pop(context, 'general'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (quizType == null) return;
    
    Book? selectedBook;
    if (quizType == 'book') {
      final books = await ApiService.getAdminBooks();
      if (!mounted) return;
      selectedBook = await showModalBottomSheet<Book>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Reference Manuscript', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: books.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey.withOpacity(0.1)),
                  itemBuilder: (context, idx) => ListTile(
                    title: Text(books[idx].title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(books[idx].author, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    onTap: () => Navigator.pop(context, books[idx]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      if (selectedBook == null) return; // User cancelled book selection
    }

    if (!mounted) return;
    final success = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateQuizScreen(selectedBook: selectedBook),
      ),
    );

    if (success == true) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.initialTabIndex == 0 ? _buildManuscriptsTab() : _buildQuizStudioTab();
  }

  Widget _buildManuscriptsTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildUploadForm(context),
          const SizedBox(height: 24),
          _buildRecentUploadsSection(),
        ],
      ),
    );
  }

  Widget _buildUploadForm(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'UPLOAD MANUSCRIPT',
            style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          _buildField('Title', _titleController, 'e.g. Advanced Calculus'),
          const SizedBox(height: 12),
          _buildField('Author', _authorController, 'e.g. John Doe'),
          const SizedBox(height: 12),
          _buildField('Description', _descriptionController, 'Brief syllabus summary...', maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFilePicker('Cover Image', _pickedCoverName, _pickCoverImage, Icons.image_rounded)),
              const SizedBox(width: 12),
              Expanded(child: _buildFilePicker('Document', _pickedFileName, _pickBookFile, Icons.picture_as_pdf_rounded)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _publishBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Publish to Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildFilePicker(String label, String? selectedName, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selectedName != null ? AppTheme.primary.withOpacity(0.1) : (Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selectedName != null ? AppTheme.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: selectedName != null ? AppTheme.primary : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                   Text(
                     selectedName ?? 'Tap to select',
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(
                       fontSize: 12,
                       fontWeight: selectedName != null ? FontWeight.bold : FontWeight.w500,
                       color: selectedName != null ? AppTheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
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

  Widget _buildRecentUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MANAGE ARCHIVES',
          style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Book>>(
          future: _booksFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final books = snapshot.data!;
            if (books.isEmpty) return const Text('No manuscripts available.', style: TextStyle(color: Colors.grey));
            return Column(
              children: books.map((book) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                              onError: (e, s) {},
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            book.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: book.isVisible ? AppTheme.primary : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _toggleBookVisibility(book),
                          tooltip: book.isVisible ? 'Hide Book' : 'Show Book',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                          onPressed: () => _editBook(book),
                          tooltip: 'Edit Details',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteBook(book.id),
                          tooltip: 'Delete Permanently',
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

  Widget _buildQuizStudioTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildQuizBanner(),
          const SizedBox(height: 24),
          _buildExistingQuizzesSection(),
        ],
      ),
    );
  }

  Widget _buildQuizBanner() {
    return GlassPanel(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.rocket_launch_rounded, color: AppTheme.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Quiz Creator Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _navigateToCreateQuiz,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('New Quiz Sequence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExistingQuizzesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACTIVE QUIZZES',
          style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Quiz>>(
          future: _quizzesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final quizzes = snapshot.data!;
            if (quizzes.isEmpty) return const Text('No active quizzes available.', style: TextStyle(color: Colors.grey));
            return Column(
              children: quizzes.map((quiz) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.quiz_rounded, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                '${quiz.questions?.length ?? 0} Questions • ${quiz.isVisible ? 'Live' : 'Hidden'}',
                                style: TextStyle(color: quiz.isVisible ? AppTheme.primary : Colors.grey, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            quiz.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: quiz.isVisible ? AppTheme.primary : Colors.grey,
                            size: 20,
                          ),
                          onPressed: () => _toggleQuizVisibility(quiz),
                          tooltip: 'Toggle Visibility',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 20),
                          onPressed: () => _editQuiz(quiz),
                          tooltip: 'Edit Sequence',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _deleteQuiz(quiz.id),
                          tooltip: 'Delete Sequence',
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
