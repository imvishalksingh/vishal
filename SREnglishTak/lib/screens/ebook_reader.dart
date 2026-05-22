import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EbookReader extends StatefulWidget {
  const EbookReader({super.key});

  @override
  State<EbookReader> createState() => _EbookReaderState();
}

class _EbookReaderState extends State<EbookReader> {
  double _progress = 0.12; // 12%

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Stack(
        children: [
          // Background Texture (Subtle)
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.03,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/parchment.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(child: _buildFileReader(context)),
              ],
            ),
          ),
          
          // Bottom Tools
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomToolbar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primary.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'The Secret History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'DONNA TARTT',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppTheme.primary.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFileReader(BuildContext context) {
    // We are simulating the text shown in the HTML
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 160),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chapter 1: The Secret History',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              
              // Simulating drop cap
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'T',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.primary,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'he snow in the mountains was melting and Bunny had been dead for several weeks before we came to understand the gravity of our situation. It was a cold, bright day in April, and the clocks were striking thirteen. The library smelled of old paper and leather-bound secrets, a sanctuary of dark oak and whispered wisdom.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'He was a man of few words, but his eyes spoke of centuries spent under the flickering candlelight of forgotten scriptoriums. We sat in silence, the only sound the scratching of a nib against parchment. The shadows stretched long across the mahogany floors, reaching for the rows of vellum spines that lined the walls like silent witnesses.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'I suppose at one time in my life I might have had any number of stories, but now there is no other. This is the only story I will ever be able to tell. It is a story of a group of clever, misfitted young people who, under the influence of their charismatic classics professor, discovered a way of thinking and living that was a world away from the humdrum existence of their contemporaries.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'The air was heavy with the scent of incense and damp earth. Outside, the world was waking up to spring, but here, inside the stone walls of the college, time seemed to have folded in on itself. We were ancient Greeks in a modern world, seekers of a beauty that was as terrifying as it was sublime.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            'PAGE 42 OF 350',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2.0,
              color: AppTheme.primary.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.primary),
                onPressed: () {},
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor: AppTheme.primary.withOpacity(0.1),
                        thumbColor: AppTheme.primary,
                        overlayColor: AppTheme.primary.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (val) {
                          setState(() {
                            _progress = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'START',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            'END',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
