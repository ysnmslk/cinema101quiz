
import 'package:cloud_firestore/cloud_firestore.dart';

class SolvedQuiz {
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime dateCompleted;
  final String level;

  SolvedQuiz({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.dateCompleted,
    required this.level,
  });

  factory SolvedQuiz.fromMap(String id, Map<String, dynamic> data) {
    return SolvedQuiz(
      // quizId field'ını kullan, yoksa document ID'sini kullan
      quizId: data['quizId'] as String? ?? id,
      quizTitle: data['quizTitle'] ?? 'İsimsiz Quiz',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      dateCompleted: (data['dateCompleted'] as Timestamp? ?? Timestamp.now()).toDate(),
      level: data['level'] ?? 'Başlangıç',
    );
  }
}
