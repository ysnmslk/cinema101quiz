
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final String imageUrl;
  final int durationMinutes;
  final Timestamp createdAt;
  List<Question>? questions; // Sonradan yüklenebilir

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.imageUrl,
    required this.durationMinutes,
    required this.createdAt,
    this.questions,
  });

  // Firestore'dan Quiz nesnesi oluşturma
  factory Quiz.fromFirestore(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      topic: data['topic'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // Firestore'a yazmak için Quiz nesnesini Map'e dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<Option> options;

  Question({required this.id, required this.text, required this.options});

  factory Question.fromFirestore(String id, Map<String, dynamic> data) {
    return Question(
      id: id,
      text: data['text'] ?? '',
      options: (data['options'] as List<dynamic>? ?? [])
          .map((opt) => Option.fromMap(opt as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }
}

class Option {
  final String text;
  final bool isCorrect;

  Option({required this.text, this.isCorrect = false});

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

// Düzeltme: Kullanıcının bir quiz'e verdiği cevabı temsil eden model
class UserQuizResult {
  final String quizId;
  final int score;
  final int totalQuestions;
  final Timestamp completedAt;

  UserQuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory UserQuizResult.fromFirestore(Map<String, dynamic> data) {
    return UserQuizResult(
      quizId: data['quizId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      completedAt: data['completedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

// Düzeltme: Profil ve sertifika ekranları için birleştirilmiş model
class QuizResultDetails {
  final UserQuizResult result;
  final Quiz quiz;

  QuizResultDetails({required this.result, required this.quiz});
}
