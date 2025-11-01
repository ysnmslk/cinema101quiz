
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

// Kullanıcının bir quize verdiği cevapları ve sonucunu saklayan model
class UserQuizResult {
  final String quizId;
  final int score;
  final int totalQuestions;
  final Timestamp dateCompleted;

  UserQuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.dateCompleted, required int correctAnswers,
  });

  // Firestore'dan okumak için
  factory UserQuizResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserQuizResult(
      quizId: doc.id, // Belge ID'sini quizId olarak kullanıyoruz
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      dateCompleted: data['dateCompleted'] as Timestamp? ?? Timestamp.now(), correctAnswers: 0,
    );
  }

  // Firestore'a yazmak için
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'dateCompleted': dateCompleted,
      // quizId, document ID olduğu için map içinde olmasına gerek yok
    };
  }
}

// Kullanıcı sonucunu ve o sonuca ait tam Quiz nesnesini birleştiren yardımcı sınıf
class UserQuizResultWithQuiz {
  final UserQuizResult result;
  final Quiz quiz;

  UserQuizResultWithQuiz({required this.result, required this.quiz});
}
