
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';
import 'package:myapp/quiz/services/quiz_service.dart';

class FirebaseQuizService implements QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _quizzesCollection =
      FirebaseFirestore.instance.collection('quizzes');

  @override
  Stream<List<Quiz>> getQuizzes() {
    return _quizzesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<Quiz?> getQuizById(String id) async {
    final doc = await _quizzesCollection.doc(id).get();
    if (doc.exists) {
      return Quiz.fromFirestore(doc);
    }
    return null;
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
  
  // Bu metotları da ekliyorum, çünkü QuizService arayüzünde tanımlanmışlar.
  @override
  Future<void> addQuiz(Quiz quiz) async {
    await _quizzesCollection.add(quiz.toMap());
  }

  @override
  Future<void> updateQuiz(Quiz quiz) async {
    await _quizzesCollection.doc(quiz.id).update(quiz.toMap());
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await _quizzesCollection.doc(id).delete();
  }
}
