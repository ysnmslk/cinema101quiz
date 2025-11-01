
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final String imageUrl;
  final int durationMinutes;
  final List<Question> questions;
  final Timestamp createdAt;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.imageUrl,
    required this.durationMinutes,
    required this.questions,
    required this.createdAt,
  });

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Quiz(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      topic: data['topic'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      questions: (data['questions'] as List<dynamic>? ?? [])
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}

class Question {
  final String text;
  final List<Option> options;
  final int correctAnswerIndex;

  const Question({required this.text, required this.options, required this.correctAnswerIndex});

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      text: map['text'] ?? '',
      options: (map['options'] as List<dynamic>? ?? [])
          .map((o) => Option.fromMap(o as Map<String, dynamic>))
          .toList(),
      correctAnswerIndex: map['correctAnswerIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options.map((o) => o.toMap()).toList(),
      'correctAnswerIndex': correctAnswerIndex,
    };
  }
}

class Option {
  final String text;

  // isCorrect parametresi kaldırıldı.
  const Option({required this.text});

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      text: map['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
    };
  }
}
