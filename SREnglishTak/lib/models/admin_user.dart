class AdminUser {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;
  final String? className;
  final String? learningGoal;

  AdminUser({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.createdAt,
    this.className,
    this.learningGoal,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      className: json['class'],
      learningGoal: json['learning_goal'],
    );
  }
}
