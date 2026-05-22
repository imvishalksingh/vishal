class Bookmark {
  final String id;
  final String userId;
  final String bookId;
  final int page;
  final String? position;
  final String? label;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.page,
    this.position,
    this.label,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      page: json['page'] ?? 0,
      position: json['position'],
      label: json['label'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
