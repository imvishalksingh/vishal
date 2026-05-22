import 'package:flutter/material.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/premium_background.dart';
import 'coming_soon_screen.dart';

class LiveWorkshopsScreen extends StatelessWidget {
  final VoidCallback? onProfileTap;

  const LiveWorkshopsScreen({super.key, this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> workshops = [
      {
        'title': 'English Grammar Masterclass',
        'instructor': 'Dr. Sharma',
        'time': 'LIVE NOW',
        'colors': [const Color(0xFF6366F1), const Color(0xFFA855F7)],
        'isLive': true,
        'icon': Icons.bolt_rounded,
      },
      {
        'title': 'Vocabulary Blueprint',
        'instructor': 'Dr. Sharma',
        'time': 'TODAY, 6:00 PM',
        'colors': [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
        'isLive': false,
        'icon': Icons.star_rounded,
      },
      {
        'title': 'Spoken English Secrets',
        'instructor': 'Dr. Sharma',
        'time': 'TOMORROW, 4:00 PM',
        'colors': [const Color(0xFF10B981), const Color(0xFF3B82F6)],
        'isLive': false,
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'title': 'IELTS Preparation Guide',
        'instructor': 'Dr. Sharma',
        'time': 'MAY 25, 2:00 PM',
        'colors': [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
        'isLive': false,
        'icon': Icons.menu_book_rounded,
      },
      {
        'title': 'Business English Writing',
        'instructor': 'Dr. Sharma',
        'time': 'MAY 28, 5:00 PM',
        'colors': [const Color(0xFF06B6D4), const Color(0xFF3B82F6)],
        'isLive': false,
        'icon': Icons.work_rounded,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          DashboardHeader(
            title: 'Live Workshops',
            subtitle: 'Learn live with expert educators.',
            onActionPressed: onProfileTap,
          ),
          Expanded(
            child: PremiumBackground(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: workshops.length,
                itemBuilder: (context, index) {
                  final ws = workshops[index];
                  final colors = ws['colors'] as List<Color>;
                  final isLive = ws['isLive'] as bool;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComingSoonScreen(
                            title: ws['title'],
                            onProfileTap: onProfileTap,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors[1].withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -10,
                            bottom: -20,
                            child: Icon(
                              ws['icon'] as IconData,
                              size: 110,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 4,
                                            backgroundColor: isLive ? Colors.redAccent : Colors.white70,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isLive ? 'LIVE NOW' : (ws['time'] as String),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isLive)
                                      const Icon(
                                        Icons.sensors_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  ws['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'with ${ws['instructor']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
