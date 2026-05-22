class Vocabulary {
  final String id;
  final String word;
  final String meaning;
  final String? exampleSentence;
  final String? category;
  final DateTime? createdAt;

  Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    this.exampleSentence,
    this.category,
    this.createdAt,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'] ?? json['_id'] ?? '',
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      exampleSentence: json['example_sentence'],
      category: json['category'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'word': word,
      'meaning': meaning,
      if (exampleSentence != null) 'example_sentence': exampleSentence,
      if (category != null) 'category': category,
    };
  }
}
