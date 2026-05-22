import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminVocabularyScreen extends StatefulWidget {
  const AdminVocabularyScreen({super.key});

  @override
  State<AdminVocabularyScreen> createState() => _AdminVocabularyScreenState();
}

class _AdminVocabularyScreenState extends State<AdminVocabularyScreen> {
  late Future<List<Vocabulary>> _vocabFuture;

  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _categoryController = TextEditingController();

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

  Future<void> _addVocabulary() async {
    if (_wordController.text.isEmpty || _meaningController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Word and Meaning are required')));
      return;
    }

    try {
      await ApiService.createVocabulary({
        'word': _wordController.text,
        'meaning': _meaningController.text,
        'example_sentence': _exampleController.text.isNotEmpty ? _exampleController.text : null,
        'category': _categoryController.text.isNotEmpty ? _categoryController.text : null,
      });

      _wordController.clear();
      _meaningController.clear();
      _exampleController.clear();
      _categoryController.clear();
      if (!mounted) return;
      Navigator.pop(context); // close modal
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Word added successfully!')));
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteVocab(String id) async {
    try {
      await ApiService.deleteVocabulary(id);
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add New Word', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildField('Word', _wordController),
                const SizedBox(height: 12),
                _buildField('Meaning', _meaningController),
                const SizedBox(height: 12),
                _buildField('Example Sentence (Optional)', _exampleController),
                const SizedBox(height: 12),
                _buildField('Category/Level (Optional)', _categoryController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addVocabulary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Vocabulary', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: FutureBuilder<List<Vocabulary>>(
                  future: _vocabFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    final words = snapshot.data ?? [];
                    if (words.isEmpty) return const Center(child: Text('No vocabulary yet.', style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: words.length,
                      itemBuilder: (context, index) {
                        final v = words[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassPanel(
                            padding: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(v.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                                      const SizedBox(height: 4),
                                      Text(v.meaning, style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteVocab(v.id),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddModal,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(child: Text('Manage Vocabulary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
