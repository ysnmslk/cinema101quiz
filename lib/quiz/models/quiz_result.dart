import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime dateCompleted;
  final List<int>? answers; // nullable yapıldı
  final DateTime? timestamp; // nullable yapıldı

  QuizResult({
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.dateCompleted,
    this.answers, // required kaldırıldı
    this.timestamp, // required kaldırıldı
  });

  // fromMap factory constructor
  factory QuizResult.fromMap(Map<String, dynamic> data) {
    return QuizResult(
      userId: data['userId'] as String,
      quizId: data['quizId'] as String,
      score: data['score'] as int,
      totalQuestions: data['totalQuestions'] as int,
      dateCompleted: (data['dateCompleted'] as Timestamp).toDate(),
      answers: (data['answers'] as List<dynamic>?)?.cast<int>(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'dateCompleted': Timestamp.fromDate(dateCompleted),
      if (answers != null) 'answers': answers,
      if (timestamp != null) 'timestamp': Timestamp.fromDate(timestamp!),
    };
  }
}