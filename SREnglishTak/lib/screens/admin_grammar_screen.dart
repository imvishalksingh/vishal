import 'package:flutter/material.dart';
import '../models/grammar_unit.dart';
import '../models/grammar_lesson.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminGrammarScreen extends StatefulWidget {
  const AdminGrammarScreen({super.key});

  @override
  State<AdminGrammarScreen> createState() => _AdminGrammarScreenState();
}

class _AdminGrammarScreenState extends State<AdminGrammarScreen> {
  late Future<List<GrammarUnit>> _unitsFuture;
  GrammarUnit? _selectedUnit;
  late Future<List<GrammarLesson>> _lessonsFuture;

  final _unitTitleController = TextEditingController();
  final _unitDescController = TextEditingController();
  final _unitOrderController = TextEditingController();

  final _lessonTitleController = TextEditingController();
  final _lessonTypeController = TextEditingController(text: 'text');
  final _lessonDataController = TextEditingController();
  final _lessonOrderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshUnits();
  }

  void _refreshUnits() {
    setState(() {
      _unitsFuture = ApiService.getGrammarUnits();
    });
  }

  void _refreshLessons() {
    if (_selectedUnit != null) {
      setState(() {
        _lessonsFuture = ApiService.getGrammarLessons(_selectedUnit!.id);
      });
    }
  }

  Future<void> _addUnit() async {
    if (_unitTitleController.text.isEmpty || _unitOrderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Order are required')));
      return;
    }

    try {
      await ApiService.createGrammarUnit({
        'title': _unitTitleController.text,
        'description': _unitDescController.text,
        'unit_order': int.tryParse(_unitOrderController.text) ?? 0,
      });

      _unitTitleController.clear();
      _unitDescController.clear();
      _unitOrderController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _refreshUnits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addLesson() async {
    if (_selectedUnit == null) return;
    if (_lessonTitleController.text.isEmpty || _lessonOrderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Order are required')));
      return;
    }

    try {
      await ApiService.createGrammarLesson(_selectedUnit!.id, {
        'title': _lessonTitleController.text,
        'content_type': _lessonTypeController.text,
        'content_data': _lessonDataController.text,
        'lesson_order': int.tryParse(_lessonOrderController.text) ?? 0,
      });

      _lessonTitleController.clear();
      _lessonDataController.clear();
      _lessonOrderController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _refreshLessons();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddUnitModal() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Grammar Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildField('Title', _unitTitleController),
              const SizedBox(height: 12),
              _buildField('Description', _unitDescController),
              const SizedBox(height: 12),
              _buildField('Order Index', _unitOrderController, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addUnit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Unit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLessonModal() {
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
              children: [
                const Text('Add Lesson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildField('Title', _lessonTitleController),
                const SizedBox(height: 12),
                _buildField('Content Type (text/pdf/video)', _lessonTypeController),
                const SizedBox(height: 12),
                _buildField('Content Data (HTML/URL)', _lessonDataController, maxLines: 5),
                const SizedBox(height: 12),
                _buildField('Lesson Order', _lessonOrderController, keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addLesson,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Lesson'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
              _buildAppBar(),
              Expanded(
                child: Row(
                  children: [
                    // Units Sidebar
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: FutureBuilder<List<GrammarUnit>>(
                        future: _unitsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final units = snapshot.data!;
                          return ListView.builder(
                            itemCount: units.length,
                            itemBuilder: (context, index) {
                              final u = units[index];
                              bool isSelected = _selectedUnit?.id == u.id;
                              return ListTile(
                                title: Text(u.title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.primary : null)),
                                selected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedUnit = u;
                                    _refreshLessons();
                                  });
                                },
                                trailing: isSelected ? const Icon(Icons.chevron_right, size: 16) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Lessons List
                    Expanded(
                      child: _selectedUnit == null
                          ? const Center(child: Text('Select a unit to manage lessons'))
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Lessons: ${_selectedUnit!.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                                        onPressed: _showAddLessonModal,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder<List<GrammarLesson>>(
                                    future: _lessonsFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                      final lessons = snapshot.data!;
                                      if (lessons.isEmpty) return const Center(child: Text('No lessons yet'));
                                      return ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: lessons.length,
                                        itemBuilder: (context, index) {
                                          final l = lessons[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              title: Text(l.title),
                                              subtitle: Text('Order: ${l.lessonOrder} | ${l.contentType ?? 'text'}'),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red),
                                                onPressed: () async {
                                                  await ApiService.deleteGrammarLesson(l.id);
                                                  _refreshLessons();
                                                },
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUnitModal,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.library_add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Manage Grammar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
