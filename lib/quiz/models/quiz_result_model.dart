
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id; // Belge ID'si
  final String userId;
  final String quizId;
  final String quizTitle;
  final String quizImageUrl; // Sertifikada göstermek için
  final int score;
  final int totalQuestions;
  final Timestamp timestamp;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.quizTitle,
    required this.quizImageUrl,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
  });

  // Firestore'dan gelen veriyi modele dönüştürmek için factory constructor
  factory QuizResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizResult(
      id: doc.id,
      userId: data['userId'] ?? '',
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? '',
      quizImageUrl: data['quizImageUrl'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Modeli Firestore'a yazmak için Map'e dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'quizImageUrl': quizImageUrl,
      'score': score,
      'totalQuestions': totalQuestions,
      'timestamp': timestamp,
    };
  }
}
