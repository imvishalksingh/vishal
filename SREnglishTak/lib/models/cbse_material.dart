class CbseMaterial {
  final String id;
  final String categoryId;
  final String? materialType; // 'model_paper', 'pyq', 'notes', 'syllabus'
  final String title;
  final String? year;
  final String? description;
  final String fileUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;

  CbseMaterial({
    required this.id,
    required this.categoryId,
    this.materialType,
    required this.title,
    this.year,
    this.description,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory CbseMaterial.fromJson(Map<String, dynamic> json) {
    return CbseMaterial(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      materialType: json['material_type'] as String?,
      title: json['title'] as String,
      year: json['year'] as String?,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'material_type': materialType,
      'title': title,
      'year': year,
      'description': description,
      'file_url': fileUrl,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
