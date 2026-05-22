import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../models/challenge_leaderboard.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';
import '../widgets/glass_panel.dart';
import 'package:intl/intl.dart';

class ChallengeLeaderboardScreen extends StatefulWidget {
  final Challenge challenge;

  const ChallengeLeaderboardScreen({super.key, required this.challenge});

  @override
  State<ChallengeLeaderboardScreen> createState() => _ChallengeLeaderboardScreenState();
}

class _ChallengeLeaderboardScreenState extends State<ChallengeLeaderboardScreen> {
  late Future<List<ChallengeLeaderboardEntry>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = ApiService.getChallengeLeaderboard(widget.challenge.id);
  }

  String _formatTime(int ms) {
    if (ms == 0) return '0s';
    final seconds = (ms / 1000).toStringAsFixed(1);
    return '${seconds}s';
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
                child: FutureBuilder<List<ChallengeLeaderboardEntry>>(
                  future: _leaderboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    }

                    final entries = snapshot.data ?? [];
                    if (entries.isEmpty) {
                      return const Center(
                        child: Text(
                          'No entries yet. Be the first!',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildTopThree(entries),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: entries.length > 3 ? entries.length - 3 : 0,
                            itemBuilder: (context, index) {
                              final entry = entries[index + 3];
                              return _buildListTile(entry, index + 4);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARENA LEADERBOARD',
                  style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                Text(
                  widget.challenge.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree(List<ChallengeLeaderboardEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (entries.length > 1) _buildPodium(entries[1], 2, 140, Colors.grey.shade400),
          if (entries.isNotEmpty) _buildPodium(entries[0], 1, 180, Colors.amber),
          if (entries.length > 2) _buildPodium(entries[2], 3, 120, Colors.brown.shade300),
        ],
      ),
    );
  }

  Widget _buildPodium(ChallengeLeaderboardEntry entry, int rank, double height, Color color) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            entry.userName.split(' ').first,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            '${entry.score} pts',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            _formatTime(entry.timeTakenMs),
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: color.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(ChallengeLeaderboardEntry entry, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '$rank',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              backgroundImage: entry.userAvatar.isNotEmpty ? NetworkImage(entry.userAvatar) : null,
              child: entry.userAvatar.isEmpty
                  ? Text(entry.userName.substring(0, 1).toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.completedAt),
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.score} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(entry.timeTakenMs),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
