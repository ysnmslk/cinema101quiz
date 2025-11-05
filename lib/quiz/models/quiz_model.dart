import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final int durationMinutes;
  final String imageUrl;
  final List<Question> questions;
  final Timestamp? createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.durationMinutes,
    required this.imageUrl,
    required this.questions,
    this.createdAt, // required kaldırıldı ve nullable yapıldı
  });

  factory Quiz.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      topic: data['topic'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'questions': questions.map((q) => q.toMap()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<dynamic> options;
  final int? correctAnswerIndex; // nullable yapıldı

  Question({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswerIndex, // required kaldırıldı
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      options: map['options'] ?? [],
      correctAnswerIndex: map['correctAnswerIndex'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      if (correctAnswerIndex != null) 'correctAnswerIndex': correctAnswerIndex,
    };
  }
}