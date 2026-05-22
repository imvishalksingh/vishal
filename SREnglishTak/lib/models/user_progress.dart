class UserProgress {
  final String id;
  final String userId;
  final String bookId;
  final int currentPage;
  final double progressPercent;
  final bool isCompleted;
  final int totalMinutesRead;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? lastPosition;
  final DateTime? lastOpenedAt;
  final DateTime lastReadAt;

  UserProgress({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.currentPage,
    required this.progressPercent,
    required this.isCompleted,
    required this.totalMinutesRead,
    this.startedAt,
    this.completedAt,
    this.lastPosition,
    this.lastOpenedAt,
    required this.lastReadAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      currentPage: json['current_page'] ?? 0,
      progressPercent: (json['progress_percent'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      totalMinutesRead: json['total_minutes_read'] ?? 0,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      lastPosition: json['last_position'],
      lastOpenedAt: json['last_opened_at'] != null ? DateTime.parse(json['last_opened_at']) : null,
      lastReadAt: DateTime.parse(json['last_read_at']),
    );
  }
}
