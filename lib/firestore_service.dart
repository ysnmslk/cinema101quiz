
import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Quiz>> getQuizzesStream() {
    return _db.collection('quizzes').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Quiz.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<Question>> getQuestionsForQuiz(String quizId) async {
    try {
      final snapshot = await _db
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) => Question.fromFirestore(doc.id, doc.data())).toList();
    } catch (e, s) {
      developer.log('Soruları getirirken hata', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> createQuiz(Quiz quiz, List<Question> questions) async {
    final quizRef = _db.collection('quizzes').doc();

    return _db.runTransaction((transaction) async {
      transaction.set(quizRef, quiz.toFirestore());
      for (final question in questions) {
        final questionRef = quizRef.collection('questions').doc();
        transaction.set(questionRef, question.toFirestore());
      }
    });
  }

  // DÜZELTME: '1users' -> 'users' olarak düzeltildi.
  Stream<Set<String>> getCompletedQuizzesStream(String userId) {
    return _db
        .collection('users') 
        .doc(userId)
        .collection('results')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  // DÜZELTME: '1users' -> 'users' olarak düzeltildi.
  Future<void> saveUserResult(String userId, String quizId, int score, int totalQuestions) async {
    try {
      final resultData = {
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'completedAt': Timestamp.now(),
      };

      await _db
          .collection('users') 
          .doc(userId)
          .collection('results')
          .doc(quizId)
          .set(resultData, SetOptions(merge: true));
    } catch (e, s) {
      developer.log('Kullanıcı sonucunu kaydederken hata', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }
  
  // DÜZELTME: '1users' -> 'users' olarak düzeltildi.
  Stream<List<QuizResultDetails>> getUserResultsWithDetailsStream(String userId) {
    final resultsStream = _db
        .collection('users') 
        .doc(userId)
        .collection('results')
        .orderBy('completedAt', descending: true)
        .snapshots();

    return resultsStream.asyncMap((resultsSnapshot) async {
      final detailedResults = <QuizResultDetails>[];
      for (final resultDoc in resultsSnapshot.docs) {
        final result = UserQuizResult.fromFirestore(resultDoc.data());
        final quizDoc = await _db.collection('quizzes').doc(result.quizId).get();
        if (quizDoc.exists) {
          final quiz = Quiz.fromFirestore(quizDoc.id, quizDoc.data()!);
          detailedResults.add(QuizResultDetails(result: result, quiz: quiz));
        }
      }
      return detailedResults;
    });
  }
}
