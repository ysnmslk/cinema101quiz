
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
    resultData['level'] = quiz.topic;
    
    await _firestore
        .collection('1users')
        .doc(result.userId)
        .collection('solvedQuizzes')
        .add(resultData);
    
    // Kullanıcı istatistiklerini güncelle - solvedQuizzes koleksiyonundan gerçek toplamları hesapla
    final solvedQuizzesSnapshot = await _firestore
        .collection('1users')
        .doc(result.userId)
        .collection('solvedQuizzes')
        .get();
    
    int totalScore = 0;
    int totalQuestions = 0;
    int quizzesSolved = solvedQuizzesSnapshot.docs.length;
    
    // Tüm solvedQuizzes'ten score ve totalQuestions değerlerini topla
    for (var doc in solvedQuizzesSnapshot.docs) {
      final data = doc.data();
      totalScore += (data['score'] as int?) ?? 0;
      totalQuestions += (data['totalQuestions'] as int?) ?? 0;
    }
    
    // Ortalama: (Toplam doğru sayısı / Toplam çözülen soru sayısı) * 100
    final averageScore = totalQuestions > 0 
        ? (totalScore / totalQuestions) * 100 
        : 0.0;
    
    // İstatistikleri güncelle
    final userRef = _firestore.collection('1users').doc(result.userId);
    await userRef.set({
      'totalScore': totalScore,
      'quizzesSolved': quizzesSolved,
      'totalQuestions': totalQuestions,
      'averageScore': averageScore,
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
