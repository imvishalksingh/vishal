import 'package:flutter/material.dart';
import '../models/cbse_category.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_background.dart';
import 'cbse_materials_list_screen.dart';

class CbseDashboardScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const CbseDashboardScreen({super.key, this.onProfileTap});

  @override
  State<CbseDashboardScreen> createState() => _CbseDashboardScreenState();
}

class _CbseDashboardScreenState extends State<CbseDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<CbseCategory>> _categoriesFuture;

  final List<Map<String, dynamic>> _defaultMaterials = [
    {'title': '10 Years Mocks', 'subtitle': 'Practice full mocks', 'icon': Icons.description_rounded, 'color': const Color(0xFF3B82F6)},
    {'title': 'Chapter PYQs', 'subtitle': 'Topic-wise history', 'icon': Icons.history_edu_rounded, 'color': const Color(0xFFF59E0B)},
    {'title': 'Expert Notes', 'subtitle': 'Quick revision', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFF10B981)},
    {'title': 'Syllabus 2025', 'subtitle': 'Latest curriculum', 'icon': Icons.format_list_bulleted_rounded, 'color': const Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _categoriesFuture = ApiService.getCbseCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DashboardHeader(
            title: 'CBSE Board',
            onActionPressed: widget.onProfileTap,
          ),
          _buildCustomTabBar(),
          Expanded(
            child: PremiumBackground(
              child: FutureBuilder<List<CbseCategory>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];
                  final hasError = snapshot.hasError;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildClassTabContent('Class 10th', categories, hasError),
                      _buildClassTabContent('Class 12th', categories, hasError),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Class 10th'),
            Tab(text: 'Class 12th'),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTabContent(String className, List<CbseCategory> categories, bool hasError) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STUDY MODULES',
            style: TextStyle(
              color: AppTheme.primary.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (hasError || categories.isEmpty) ...[
            if (hasError)
              _buildRetryCard()
            else
              _buildDefaultGrid(className),
          ] else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(categories[index], className);
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }



  Widget _buildDefaultGrid(String className) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _defaultMaterials.length,
      itemBuilder: (context, index) {
        final item = _defaultMaterials[index];
        return _buildModuleCard(
          title: item['title'],
          subtitle: item['subtitle'],
          icon: item['icon'],
          color: item['color'],
          onTap: () {},
          isComingSoon: true,
        );
      },
    );
  }

  Widget _buildCategoryCard(CbseCategory category, String className) {
    return _buildModuleCard(
      title: category.name,
      subtitle: category.description ?? 'Study Materials',
      icon: Icons.folder_copy_rounded,
      color: AppTheme.primary,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CbseMaterialsListScreen(
              categoryId: category.id,
              categoryTitle: category.name,
              className: className,
            ),
          ),
        );
      },
    );
  }

  Widget _buildModuleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isComingSoon ? 'Coming Soon' : subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isComingSoon ? AppTheme.primary : Colors.grey.shade500,
                  fontWeight: isComingSoon ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetryCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Connection issue', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _categoriesFuture = ApiService.getCbseCategories();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
