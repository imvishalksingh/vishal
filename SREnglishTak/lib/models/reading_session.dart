class ReadingSession {
  final String id;
  final String userId;
  final String bookId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int startPage;
  final int endPage;
  final int pagesRead;
  final int minutesSpent;
  final String? deviceType;
  final String? source;
  final bool isCompleted;

  ReadingSession({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.startedAt,
    this.endedAt,
    required this.startPage,
    required this.endPage,
    required this.pagesRead,
    required this.minutesSpent,
    this.deviceType,
    this.source,
    required this.isCompleted,
  });

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      startPage: json['start_page'] ?? 0,
      endPage: json['end_page'] ?? 0,
      pagesRead: json['pages_read'] ?? 0,
      minutesSpent: json['minutes_spent'] ?? 0,
      deviceType: json['device_type'],
      source: json['source'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}
