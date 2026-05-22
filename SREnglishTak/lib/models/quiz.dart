class Quiz {
  final String id;
  final String? bookId;
  final String type;
  final String title;
  final String description;
  final int durationMinutes;
  final List<Question>? questions;
  final bool hasSubmitted;
  final bool isVisible;

  Quiz({
    required this.id,
    this.bookId,
    required this.type,
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.questions,
    this.hasSubmitted = false,
    this.isVisible = true,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final bookId = json['book_id'];
    return Quiz(
      id: json['id'],
      bookId: bookId,
      type: json['type'] ?? (bookId == null ? 'general' : 'book'),
      title: json['title'],
      description: json['description'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((i) => Question.fromJson(i)).toList()
          : null,
      hasSubmitted: json['has_submitted'] ?? false,
      isVisible: json['is_visible'] ?? true,
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final String? imageUrl;
  final List<QuizOption> options;
  final int correctOptionIndex;
  final String? explanation;

  Question({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsList = (json['options'] as List)
        .map((i) => QuizOption.fromJson(i))
        .toList();

    return Question(
      id: json['id'],
      questionText: json['question_text'],
      imageUrl: json['image_url'],
      options: optionsList,
      correctOptionIndex: json['correct_option_index'],
      explanation: json['explanation'],
    );
  }
}

class QuizOption {
  final String label;
  final String text;

  QuizOption({required this.label, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      label: json['label'],
      text: json['text'],
    );
  }
}
