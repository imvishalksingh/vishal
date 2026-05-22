class Challenge {
  final String id;
  final String name;
  final String? description;
  final String? prizeText;
  final String? imageUrl;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final List<ChallengeQuestion> questions;
  final bool hasSubmitted;

  Challenge({
    required this.id,
    required this.name,
    this.description,
    this.prizeText,
    this.imageUrl,
    this.startTime,
    this.endTime,
    this.durationMinutes,
    this.questions = const [],
    this.hasSubmitted = false,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      prizeText: json['prize_text'],
      imageUrl: json['image_url'],
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : null,
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      durationMinutes: json['duration_minutes'],
      questions: json['challenge_questions'] != null
          ? (json['challenge_questions'] as List)
              .map((q) => ChallengeQuestion.fromJson(q))
              .toList()
          : [],
      hasSubmitted: json['has_submitted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'prize_text': prizeText,
      'image_url': imageUrl,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  bool get isActive {
    if (startTime == null || endTime == null) return true;
    final now = DateTime.now().toUtc();
    // Allow a 12 hour buffer for "active" to handle server/client drift
    return now.isAfter(startTime!.toUtc().subtract(const Duration(hours: 12))) && 
           now.isBefore(endTime!.toUtc().add(const Duration(hours: 12)));
  }

  bool get isUpcoming {
    if (startTime == null) return false;
    return DateTime.now().toUtc().isBefore(startTime!.toUtc());
  }
}

class ChallengeQuestion {
  final String id;
  final String? category;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  ChallengeQuestion({
    required this.id,
    this.category,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory ChallengeQuestion.fromJson(Map<String, dynamic> json) {
    return ChallengeQuestion(
      id: json['id'] ?? '',
      category: json['category'],
      questionText: json['question_text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correct_option_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
    };
  }
}
