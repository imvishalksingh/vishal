class UserInsights {
  final int currentStreak;
  final int longestStreak;
  final int readingMinutesToday;
  final int activeDays;
  final int completedBooks;
  final int quizAttempts;
  final int totalSessions;
  final int achievementsUnlocked;

  UserInsights({
    required this.currentStreak,
    required this.longestStreak,
    required this.readingMinutesToday,
    required this.activeDays,
    required this.completedBooks,
    required this.quizAttempts,
    required this.totalSessions,
    required this.achievementsUnlocked,
  });

  factory UserInsights.fromJson(Map<String, dynamic> json) {
    return UserInsights(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      readingMinutesToday: json['reading_minutes_today'] ?? 0,
      activeDays: json['active_days'] ?? 0,
      completedBooks: json['completed_books'] ?? 0,
      quizAttempts: json['quiz_attempts'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      achievementsUnlocked: json['achievements_unlocked'] ?? 0,
    );
  }
}
