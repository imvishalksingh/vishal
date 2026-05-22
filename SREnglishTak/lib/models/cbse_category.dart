class CbseCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final int orderIndex;
  final DateTime createdAt;

  CbseCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.orderIndex,
    required this.createdAt,
  });

  factory CbseCategory.fromJson(Map<String, dynamic> json) {
    return CbseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      orderIndex: json['order_index'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
