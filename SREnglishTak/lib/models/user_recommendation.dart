class UserRecommendation {
  final String kind;
  final String recommendationType;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String? bookId;
  final String? quizType;
  final String? coverUrl;
  final String? fileUrl;
  final String? formatType;

  UserRecommendation({
    required this.kind,
    required this.recommendationType,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.bookId,
    this.quizType,
    this.coverUrl,
    this.fileUrl,
    this.formatType,
  });

  factory UserRecommendation.fromJson(Map<String, dynamic> json) {
    return UserRecommendation(
      kind: json['kind'] ?? 'book',
      recommendationType: json['recommendation_type'] ?? 'new_book',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      actionLabel: json['action_label'] ?? 'Open',
      bookId: json['book_id'],
      quizType: json['quiz_type'],
      coverUrl: json['cover_url'],
      fileUrl: json['file_url'],
      formatType: json['format_type'],
    );
  }
}
