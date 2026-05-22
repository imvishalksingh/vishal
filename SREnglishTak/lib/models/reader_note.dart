class ReaderNote {
  final String id;
  final String userId;
  final String bookId;
  final int page;
  final String? position;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReaderNote({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.page,
    this.position,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReaderNote.fromJson(Map<String, dynamic> json) {
    return ReaderNote(
      id: json['id'],
      userId: json['user_id'],
      bookId: json['book_id'],
      page: json['page'] ?? 0,
      position: json['position'],
      noteText: json['note_text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
