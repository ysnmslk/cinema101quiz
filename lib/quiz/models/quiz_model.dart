


// --- Option (Seçenek) Modeli ---
class Option {
  String text;
  bool isCorrect;

  Option({required this.text, this.isCorrect = false});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

// --- Question (Soru) Modeli ---
class Question {
  final String id;
  String text; // questionText değil, sadece text
  List<Option> options;
  int correctAnswerIndex;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    // Doğru cevap indeksine göre seçeneklerin isCorrect alanını ayarla
    for (int i = 0; i < options.length; i++) {
      options[i].isCorrect = (i == correctAnswerIndex);
    }
    return {
      'id': id,
      'text': text, // Standart alan adı: text
      'options': options.map((opt) => opt.toMap()).toList(),
      // Not: correctAnswerIndex'i doğrudan kaydetmiyoruz,
      // çünkü bu bilgi options listesindeki isCorrect alanında zaten mevcut.
    };
  }

  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    var optionsList = (map['options'] as List<dynamic>? ?? [])
        .map((optionMap) => Option.fromMap(optionMap))
        .toList();

    int correctIndex = optionsList.indexWhere((opt) => opt.isCorrect);
    if (correctIndex == -1) correctIndex = 0; // Güvenlik için

    return Question(
      id: documentId,
      text: map['text'] ?? '', // Standart alan adı: text
      options: optionsList,
      correctAnswerIndex: correctIndex,
    );
  }
}

// --- Quiz Modeli ---
class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int durationMinutes;
  final int totalQuestions;
  List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.durationMinutes,
    required this.totalQuestions,
    this.questions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'durationMinutes': durationMinutes,
      'totalQuestions': totalQuestions,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map, String documentId) {
    return Quiz(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
    );
  }
}
