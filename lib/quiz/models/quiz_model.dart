
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String text;
  List<Option> options;
  int correctAnswerIndex;

  Question({
    this.id = '',
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    for (int i = 0; i < options.length; i++) {
      options[i].isCorrect = (i == correctAnswerIndex);
    }
    return {
      'text': text,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    var optionsList = (map['options'] as List<dynamic>? ?? [])
        .map((optionMap) => Option.fromMap(optionMap))
        .toList();

    int correctIndex = optionsList.indexWhere((opt) => opt.isCorrect);

    return Question(
      id: documentId,
      text: map['text'] ?? '',
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
    this.id = '',
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.durationMinutes = 0,
    this.totalQuestions = 0,
    this.questions = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'durationMinutes': durationMinutes,
      'totalQuestions': questions.length,
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

// --- QuizResult (Quiz Sonucu) Modeli ---
class QuizResult {
  final String? id;
  final String quizId;
  final String userId;
  final int score;
  final int totalQuestions;
  final Timestamp timestamp;
  final List<int> userAnswers; // TİP GÜNCELLENDİ: List<int>

  // UI'da kullanılacak, veritabanında saklanmayacak alanlar
  final String quizTitle;
  final String quizImageUrl;

  QuizResult({
    this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    required this.userAnswers, // TİP GÜNCELLENDİ
    this.quizTitle = '',
    this.quizImageUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp, // Doğrudan Timestamp nesnesi kullanılıyor
      'userAnswers': userAnswers, // TİP GÜNCELLENDİ
      // UI için gerekli verileri de sonucun içine gömüyoruz.
      'quizTitle': quizTitle,
      'quizImageUrl': quizImageUrl,
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map, String documentId) {
    return QuizResult(
      id: documentId,
      quizId: map['quizId'] ?? '',
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timestamp: map['timestamp'] as Timestamp? ?? Timestamp.now(),
      // GÜNCELLENDİ: List<int> olarak okunuyor
      userAnswers: List<int>.from(map['userAnswers'] ?? []),
      quizTitle: map['quizTitle'] ?? '', 
      quizImageUrl: map['quizImageUrl'] ?? '',
    );
  }
}
