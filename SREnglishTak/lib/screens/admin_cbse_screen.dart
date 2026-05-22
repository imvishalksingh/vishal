import 'package:flutter/material.dart';
import '../models/cbse_category.dart';
import '../models/cbse_material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';

class AdminCbseScreen extends StatefulWidget {
  const AdminCbseScreen({super.key});

  @override
  State<AdminCbseScreen> createState() => _AdminCbseScreenState();
}

class _AdminCbseScreenState extends State<AdminCbseScreen> {
  late Future<List<CbseCategory>> _categoriesFuture;
  CbseCategory? _selectedCategory;
  late Future<List<CbseMaterial>> _materialsFuture;

  final _catNameController = TextEditingController();
  final _catDescController = TextEditingController();
  final _catIconController = TextEditingController();

  final _matTitleController = TextEditingController();
  final _matTypeController = TextEditingController(text: 'pdf');
  final _matUrlController = TextEditingController();
  final _matThumbController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = ApiService.getCbseCategories();
    });
  }

  void _refreshMaterials() {
    if (_selectedCategory != null) {
      setState(() {
        _materialsFuture = ApiService.getCbseMaterials(_selectedCategory!.id);
      });
    }
  }

  Future<void> _addCategory() async {
    if (_catNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    try {
      await ApiService.createCbseCategory({
        'name': _catNameController.text,
        'description': _catDescController.text,
        'icon_url': _catIconController.text,
      });

      _catNameController.clear();
      _catDescController.clear();
      _catIconController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _refreshCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _addMaterial() async {
    if (_selectedCategory == null) return;
    if (_matTitleController.text.isEmpty || _matUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and URL are required')));
      return;
    }

    try {
      await ApiService.createCbseMaterial(_selectedCategory!.id, {
        'title': _matTitleController.text,
        'material_type': _matTypeController.text,
        'file_url': _matUrlController.text,
        'thumbnail_url': _matThumbController.text,
      });

      _matTitleController.clear();
      _matUrlController.clear();
      _matThumbController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _refreshMaterials();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddCategoryModal() {
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
              const Text('Add CBSE Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              _buildField('Category Name (e.g. Class 10 Notes)', _catNameController),
              const SizedBox(height: 12),
              _buildField('Description', _catDescController),
              const SizedBox(height: 12),
              _buildField('Icon URL (Optional)', _catIconController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMaterialModal() {
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
                const Text('Add Material', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                _buildField('Title', _matTitleController),
                const SizedBox(height: 12),
                _buildField('Material Type (pdf/video/link)', _matTypeController),
                const SizedBox(height: 12),
                _buildField('File URL', _matUrlController),
                const SizedBox(height: 12),
                _buildField('Thumbnail URL (Optional)', _matThumbController),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addMaterial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save Material'),
                ),
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
              _buildAppBar(),
              Expanded(
                child: Row(
                  children: [
                    // Categories Sidebar
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
                      ),
                      child: FutureBuilder<List<CbseCategory>>(
                        future: _categoriesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final categories = snapshot.data!;
                          return ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final c = categories[index];
                              bool isSelected = _selectedCategory?.id == c.id;
                              return ListTile(
                                title: Text(c.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.blueAccent : null)),
                                selected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = c;
                                    _refreshMaterials();
                                  });
                                },
                                trailing: isSelected ? const Icon(Icons.chevron_right, size: 16) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Materials List
                    Expanded(
                      child: _selectedCategory == null
                          ? const Center(child: Text('Select a category to manage materials'))
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('Materials: ${_selectedCategory!.name}', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                                        onPressed: _showAddMaterialModal,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder<List<CbseMaterial>>(
                                    future: _materialsFuture,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                                      final materials = snapshot.data!;
                                      if (materials.isEmpty) return const Center(child: Text('No materials yet'));
                                      return ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        itemCount: materials.length,
                                        itemBuilder: (context, index) {
                                          final m = materials[index];
                                          return Card(
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              leading: const Icon(Icons.description, color: Colors.blueAccent),
                                              title: Text(m.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                              subtitle: Text(m.materialType ?? 'material', style: const TextStyle(fontSize: 12)),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                onPressed: () async {
                                                  await ApiService.deleteCbseMaterial(m.id);
                                                  _refreshMaterials();
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
        onPressed: _showAddCategoryModal,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.category, color: Colors.white),
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
          const Text('Manage CBSE Hub', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
