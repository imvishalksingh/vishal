class GrammarLesson {
  final String id;
  final String unitId;
  final String title;
  final String? contentType; // 'text', 'pdf', 'video'
  final String? contentData;
  final int lessonOrder;
  final DateTime createdAt;

  GrammarLesson({
    required this.id,
    required this.unitId,
    required this.title,
    this.contentType,
    this.contentData,
    required this.lessonOrder,
    required this.createdAt,
  });

  factory GrammarLesson.fromJson(Map<String, dynamic> json) {
    return GrammarLesson(
      id: json['id'] as String,
      unitId: json['unit_id'] as String,
      title: json['title'] as String,
      contentType: json['content_type'] as String?,
      contentData: json['content_data'] as String?,
      lessonOrder: json['lesson_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'title': title,
      'content_type': contentType,
      'content_data': contentData,
      'lesson_order': lessonOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
