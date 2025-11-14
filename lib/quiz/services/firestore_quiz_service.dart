import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';
import 'package:myapp/quiz/services/quiz_service.dart';

class FirestoreQuizService implements QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Quiz>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Quiz.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Quiz?> getQuizById(String id) async {
    final doc = await _firestore.collection('quizzes').doc(id).get();
    if (!doc.exists) return null;
    return Quiz.fromFirestore(doc);
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').add(quiz.toMap());
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await _firestore.collection('quizzes').doc(id).delete();
  }

  Future<void> submitResult(QuizResult result) async {
    await _firestore.collection('results').add(result.toMap());
  }

  @override
  Future<void> submitQuizResult(QuizResult result, Quiz quiz) async {
    // Quiz sonucunu kaydet
    final resultData = result.toMap();
    resultData['quizTitle'] = quiz.title;
    resultData['level'] = quiz.topic ?? 'Başlangıç';
    
    await _firestore
        .collection('users')
        .doc(result.userId)
        .collection('solvedQuizzes')
        .add(resultData);
    
    // Kullanıcı istatistiklerini güncelle
    final userRef = _firestore.collection('users').doc(result.userId);
    final userDoc = await userRef.get();
    
    final currentTotalScore = (userDoc.data()?['totalScore'] as int?) ?? 0;
    final currentQuizzesSolved = (userDoc.data()?['quizzesSolved'] as int?) ?? 0;
    final currentAverageScore = (userDoc.data()?['averageScore'] as double?) ?? 0.0;
    
    final newTotalScore = currentTotalScore + result.score;
    final newQuizzesSolved = currentQuizzesSolved + 1;
    final newAverageScore = (newTotalScore / (newQuizzesSolved * result.totalQuestions)) * 100;
    
    await userRef.set({
      'totalScore': newTotalScore,
      'quizzesSolved': newQuizzesSolved,
      'averageScore': newAverageScore,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).update(quiz.toMap());
  }
}