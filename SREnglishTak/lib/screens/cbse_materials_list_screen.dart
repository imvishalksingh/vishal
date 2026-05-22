import 'package:flutter/material.dart';
import '../models/cbse_material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_panel.dart';
import '../widgets/premium_background.dart';

class CbseMaterialsListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final String className;

  const CbseMaterialsListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    required this.className,
  });

  @override
  State<CbseMaterialsListScreen> createState() => _CbseMaterialsListScreenState();
}

class _CbseMaterialsListScreenState extends State<CbseMaterialsListScreen> {
  late Future<List<CbseMaterial>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _materialsFuture = ApiService.getCbseMaterials(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: PremiumBackground(
              child: FutureBuilder<List<CbseMaterial>>(
                future: _materialsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final materials = snapshot.data ?? [];

                  if (materials.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                widget.className,
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${materials.length} Materials Found',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                          itemCount: materials.length,
                          itemBuilder: (context, index) {
                            return _buildMaterialItem(materials[index]);
                          },
                        ),
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8), Colors.white],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Select material to view or download',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialItem(CbseMaterial material) {
    final isPdf = material.materialType?.toLowerCase() != 'video';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isPdf ? Colors.red : AppTheme.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf_rounded : Icons.play_circle_filled_rounded,
                    color: isPdf ? Colors.red : AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            material.materialType?.replaceAll('_', ' ').toUpperCase() ?? 'DOCUMENT',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          if (material.year != null) ...[
                            Text(' • ', style: TextStyle(color: Colors.grey.shade400)),
                            Text(material.year!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Something went wrong', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Check your connection and try again', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {
              _materialsFuture = ApiService.getCbseMaterials(widget.categoryId);
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          const Text('Coming Soon!', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          const Text('We are adding materials for this category.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
