import 'user_insights.dart';

class UserAchievement {
  final String id;
  final String code;
  final String title;
  final String description;
  final DateTime unlockedAt;

  UserAchievement({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.unlockedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      code: json['code'],
      title: json['title'],
      description: json['description'],
      unlockedAt: DateTime.parse(json['unlocked_at']),
    );
  }
}

class UserAchievementBundle {
  final UserInsights summary;
  final List<UserAchievement> achievements;

  UserAchievementBundle({
    required this.summary,
    required this.achievements,
  });

  factory UserAchievementBundle.fromJson(Map<String, dynamic> json) {
    final achievementsJson = json['achievements'] as List? ?? [];
    return UserAchievementBundle(
      summary: UserInsights.fromJson(json['summary'] ?? const {}),
      achievements: achievementsJson
          .map((item) => UserAchievement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
