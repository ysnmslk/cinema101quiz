
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/profile/models/solved_quiz.dart';
import 'package:myapp/profile/services/firestore_service.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

class FirebaseFirestoreService implements FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<SolvedQuiz>> getSolvedQuizzes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('solvedQuizzes')
        .orderBy('dateCompleted', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SolvedQuiz.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return {
          'totalScore': userDoc.get('totalScore') ?? 0,
          'quizzesSolved': userDoc.get('quizzesSolved') ?? 0,
          'averageScore': userDoc.get('averageScore') ?? 0.0,
        };
      } else {
        return {
          'totalScore': 0,
          'quizzesSolved': 0,
          'averageScore': 0.0,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user stats: $e');
      }
      return {
        'totalScore': 0,
        'quizzesSolved': 0,
        'averageScore': 0.0,
      };
    }
  }

  @override
  Stream<List<QuizResultDetails>> getUserResultsWithDetailsStream(String userId) {
    final resultsStream = _firestore
        .collection('users')
        .doc(userId)
        .collection('results')
        .orderBy('completedAt', descending: true)
        .snapshots();

    return resultsStream.asyncMap((resultsSnapshot) async {
      final detailedResults = <QuizResultDetails>[];
      for (final resultDoc in resultsSnapshot.docs) {
        final result = UserQuizResult.fromFirestore(resultDoc.data());
        final quizDoc = await _firestore.collection('quizzes').doc(result.quizId).get();
        if (quizDoc.exists) {
          final quiz = Quiz.fromFirestore(quizDoc.id, quizDoc.data()!);
          detailedResults.add(QuizResultDetails(result: result, quiz: quiz));
        }
      }
      return detailedResults;
    });
  }
}
