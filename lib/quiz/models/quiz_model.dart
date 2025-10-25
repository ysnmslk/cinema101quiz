
import 'package:myapp/quiz/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;       // Yeni alan
  final int totalQuestions;    // Yeni alan
  final int durationMinutes;   // Yeni alan
  List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.category = 'Genel',
    this.totalQuestions = 0,
    this.durationMinutes = 0,
    this.questions = const [],
  });

  // Firestore'dan veri okurken bu kurucu kullanılır
  factory Quiz.fromMap(Map<String, dynamic> map, String documentId) {
    return Quiz(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // Veritabanındaki alan adlarıyla eşleştirme (farklı yazımlar olabilir)
      category: map['category'] ?? 'Genel',
      totalQuestions: (map['totalQuestions'] ?? map['totalquestion'] ?? 0) as int,
      durationMinutes: (map['durationMinutes'] ?? 0) as int,
    );
  }

  // Yeni bir quiz oluştururken kullanılan, değiştirilebilir bir kopya metodu
  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? category,
    int? totalQuestions,
    int? durationMinutes,
    List<Question>? questions,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      questions: questions ?? this.questions,
    );
  }
}
