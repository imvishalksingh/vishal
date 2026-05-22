class DailyTip {
  final String id;
  final String title;
  final String content;
  final String? author;
  final String? imageUrl;
  final DateTime? createdAt;

  DailyTip({
    required this.id,
    required this.title,
    required this.content,
    this.author,
    this.imageUrl,
    this.createdAt,
  });

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      author: json['author'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'title': title,
      'content': content,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }
}
