class GrammarUnit {
  final String id;
  final String title;
  final String? description;
  final int unitOrder;
  final String? imageUrl;
  final DateTime createdAt;

  GrammarUnit({
    required this.id,
    required this.title,
    this.description,
    required this.unitOrder,
    this.imageUrl,
    required this.createdAt,
  });

  factory GrammarUnit.fromJson(Map<String, dynamic> json) {
    return GrammarUnit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      unitOrder: json['unit_order'] as int,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unit_order': unitOrder,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
