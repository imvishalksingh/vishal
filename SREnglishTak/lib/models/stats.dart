class AdminStats {
  final int totalBooks;
  final int totalUsers;
  final int totalQuizzes;
  final int activeReaders;
  final int totalReadingSessions;
  final int readingMinutesToday;
  final int activeReaders7d;
  final int completedBooks;
  final int quizAttempts;
  final double averageQuizScore;
  final int generalQuizzes;
  final int bookQuizzes;

  AdminStats({
    required this.totalBooks,
    required this.totalUsers,
    required this.totalQuizzes,
    required this.activeReaders,
    required this.totalReadingSessions,
    required this.readingMinutesToday,
    required this.activeReaders7d,
    required this.completedBooks,
    required this.quizAttempts,
    required this.averageQuizScore,
    required this.generalQuizzes,
    required this.bookQuizzes,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalBooks: json['total_books'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      activeReaders: json['active_readers'] ?? 0,
      totalReadingSessions: json['total_reading_sessions'] ?? 0,
      readingMinutesToday: json['reading_minutes_today'] ?? 0,
      activeReaders7d: json['active_readers_7d'] ?? 0,
      completedBooks: json['completed_books'] ?? 0,
      quizAttempts: json['quiz_attempts'] ?? 0,
      averageQuizScore: (json['average_quiz_score'] ?? 0).toDouble(),
      generalQuizzes: json['general_quizzes'] ?? 0,
      bookQuizzes: json['book_quizzes'] ?? 0,
    );
  }
}
