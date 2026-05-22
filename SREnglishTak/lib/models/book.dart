class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String formatType; // 'pdf' or 'epub'
  final String? fileUrl;
  final String? coverUrl;
  final bool isVisible;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    required this.formatType,
    this.fileUrl,
    this.coverUrl,
    required this.isVisible,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'] ?? 'Unknown Author',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      formatType: json['format_type'] ?? 'pdf',
      fileUrl: json['file_url'],
      coverUrl: json['cover_url'],
      isVisible: json['is_visible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'format_type': formatType,
      'file_url': fileUrl,
      'cover_url': coverUrl,
      'is_visible': isVisible,
    };
  }
}
