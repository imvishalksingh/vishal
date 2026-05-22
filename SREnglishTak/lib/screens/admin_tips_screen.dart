import 'package:flutter/material.dart';
import '../models/daily_tip.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminTipsScreen extends StatefulWidget {
  const AdminTipsScreen({super.key});

  @override
  State<AdminTipsScreen> createState() => _AdminTipsScreenState();
}

class _AdminTipsScreenState extends State<AdminTipsScreen> {
  late Future<List<DailyTip>> _tipsFuture;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _tipsFuture = ApiService.getDailyTips();
    });
  }

  Future<void> _addTip() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Content are required')));
      return;
    }

    try {
      await ApiService.createDailyTip({
        'title': _titleController.text,
        'content': _contentController.text,
        'author': _authorController.text.isNotEmpty ? _authorController.text : 'Team',
      });

      _titleController.clear();
      _contentController.clear();
      _authorController.clear();
      if (!mounted) return;
      Navigator.pop(context); // close modal
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tip added successfully!')));
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteTip(String id) async {
    try {
      await ApiService.deleteDailyTip(id);
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
                const Text('Add Daily Tip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildField('Title', _titleController),
                const SizedBox(height: 12),
                _buildField('Content', _contentController, maxLines: 4),
                const SizedBox(height: 12),
                _buildField('Author (Optional)', _authorController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addTip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Tip', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
                child: FutureBuilder<List<DailyTip>>(
                  future: _tipsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    final tips = snapshot.data ?? [];
                    if (tips.isEmpty) return const Center(child: Text('No tips yet.', style: TextStyle(color: Colors.grey)));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tips.length,
                      itemBuilder: (context, index) {
                        final t = tips[index];
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
                                      Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accent)),
                                      const SizedBox(height: 4),
                                      Text(t.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _deleteTip(t.id),
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
        backgroundColor: AppTheme.accent,
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
            icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(child: Text('Manage Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
