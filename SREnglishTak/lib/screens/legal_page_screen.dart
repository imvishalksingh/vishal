import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';

class LegalPageScreen extends StatelessWidget {
  final String title;
  final String content;
  const LegalPageScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  physics: const BouncingScrollPhysics(),
                  child: _buildMarkdownContent(context, content),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lines = text.trim().split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            line.replaceFirst('## ', ''),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
        ));
      } else if (line.startsWith('**') && line.endsWith('**') && !line.contains('**: ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(
            line.replaceAll('**', ''),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ));
      } else if (line.startsWith('**') && line.contains('**')) {
        // Bold label + rest e.g. **Q: blah** blah
        final cleaned = line.replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (m) => m.group(1)!,
        );
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Text(
            cleaned,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
        ));
      } else if (line.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 9),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  line.substring(2),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 4));
      } else {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            line.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (m) => m.group(1)!),
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
