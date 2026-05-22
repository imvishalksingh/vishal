class ChallengeLeaderboardEntry {
  final String id;
  final int score;
  final int timeTakenMs;
  final DateTime completedAt;
  final String userId;
  final String userName;
  final String userAvatar;

  ChallengeLeaderboardEntry({
    required this.id,
    required this.score,
    required this.timeTakenMs,
    required this.completedAt,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  factory ChallengeLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? {};
    return ChallengeLeaderboardEntry(
      id: json['id'] ?? '',
      score: json['score'] ?? 0,
      timeTakenMs: json['time_taken_ms'] ?? 0,
      completedAt: DateTime.parse(json['completed_at'] ?? DateTime.now().toIso8601String()),
      userId: profile['id'] ?? '',
      userName: profile['full_name'] ?? 'Unknown User',
      userAvatar: profile['avatar_url'] ?? '',
    );
  }
}
