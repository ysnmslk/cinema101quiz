
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- QUIZ OKUMA VE YAZMA METOTLARI ---

  Future<List<Quiz>> getQuizzes() async {
    var snapshot = await _db.collection('quizzes').get();
    return snapshot.docs
        .map((doc) => Quiz.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<Quiz?> getQuizById(String quizId) async {
    var quizDoc = await _db.collection('quizzes').doc(quizId).get();
    if (!quizDoc.exists || quizDoc.data() == null) {
      return null;
    }
    Quiz quiz = Quiz.fromMap(quizDoc.data()!, quizDoc.id);
    var questionsSnapshot = await _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    if (questionsSnapshot.docs.isNotEmpty) {
      quiz.questions = questionsSnapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
    }
    return quiz;
  }

  Future<void> addQuiz(Quiz quiz) async {
    WriteBatch batch = _db.batch();
    DocumentReference quizRef = _db.collection('quizzes').doc();
    batch.set(quizRef, quiz.toMap());
    for (var question in quiz.questions) {
      DocumentReference questionRef = quizRef.collection('questions').doc();
      batch.set(questionRef, question.toMap());
    }
    await batch.commit();
  }

  // --- YENİ EKLENEN METOTLAR: QUIZ SONUÇLARI ---

  /// Bir quiz sonucunu Firestore'a kaydeder.
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _db.collection('quiz_results').add(result.toMap());
    } catch (e) {
      // Hata yönetimi (örn: loglama)
      rethrow; // Hatayı üst katmana bildir
    }
  }

  /// Belirli bir kullanıcının tüm quiz sonuçlarını getirir.
  /// Sonuçlar en yeniden en eskiye doğru sıralanır.
  Future<List<QuizResult>> getUserQuizResults(String userId) async {
    try {
      var snapshot = await _db
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true) // 'dateCompleted' yerine 'timestamp' kullanıldı
          .get();
          
      return snapshot.docs
          .map((doc) => QuizResult.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, s) {
      developer.log(
        'Kullanıcı quiz sonuçları getirilirken hata oluştu',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      return []; // Hata durumunda boş liste döndür
    }
  }
}
