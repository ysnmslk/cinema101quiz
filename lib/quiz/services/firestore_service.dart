
import 'dart:async';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';
import '../models/user_quiz_result.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- QUIZ OKUMA VE YAZMA METOTLARI ---

  Future<List<Quiz>> getQuizzes() async {
    try {
      var snapshot = await _db.collection('quizzes').get();
      return snapshot.docs
          .map((doc) => Quiz.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, s) {
      developer.log('Quizler getirilirken hata', name: 'FirestoreService', error: e, stackTrace: s);
      return [];
    }
  }

  Future<Quiz?> getQuizById(String quizId) async {
    try {
      var quizDoc = await _db.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists || quizDoc.data() == null) return null;
      
      Quiz quiz = Quiz.fromMap(quizDoc.data()!, quizDoc.id);
      var questionsSnapshot = await _db.collection('quizzes').doc(quizId).collection('questions').get();
      
      if (questionsSnapshot.docs.isNotEmpty) {
        quiz.questions = questionsSnapshot.docs
            .map((doc) => Question.fromMap(doc.data(), doc.id))
            .toList();
      }
      return quiz;
    } catch (e, s) {
      developer.log('Quiz ID ile getirilirken hata', name: 'FirestoreService', error: e, stackTrace: s);
      return null;
    }
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

  // --- QUIZ SONUÇLARI METOTLARI ---

  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _db.collection('quiz_results').add(result.toMap());
    } catch (e, s) {
      developer.log('Quiz sonucu kaydedilirken hata', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }

  // --- GÜNCELLENMİŞ VE DAHA SAĞLAM METOT ---
  Future<List<UserQuizResult>> getUserResultsWithQuizDetails(String userId) async {
    if (userId.isEmpty) {
        developer.log("Geçersiz kullanıcı ID'si: userId boş.", name: 'FirestoreService');
        return [];
    }

    try {
      // 1. Kullanıcının sonuçlarını ve tüm quizleri paralel olarak çek
      final resultsFuture = _db.collection('quiz_results').where('userId', isEqualTo: userId).get();
      final quizzesFuture = getQuizzes();

      final List<dynamic> responses = await Future.wait([resultsFuture, quizzesFuture]);

      final QuerySnapshot resultsSnapshot = responses[0] as QuerySnapshot;
      final List<Quiz> allQuizzes = responses[1] as List<Quiz>;

      if (resultsSnapshot.docs.isEmpty) {
        developer.log('Bu kullanıcı için hiç sonuç bulunamadı.', name: 'FirestoreService');
        return [];
      }

      // Quizleri bir haritada topla (ID'ye göre hızlı erişim için)
      final Map<String, Quiz> quizMap = {for (var q in allQuizzes) q.id: q};

      // 2. Sonuçları bellekte işle ve birleştir
      List<UserQuizResult> userResults = [];
      for (var doc in resultsSnapshot.docs) {
        QuizResult result = QuizResult.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        if (quizMap.containsKey(result.quizId)) {
          userResults.add(UserQuizResult(quiz: quizMap[result.quizId]!, result: result));
        } else {
          developer.log(
            'Eşleşmeyen quizId bulundu! Sonuç ID: ${doc.id}, Quiz ID: ${result.quizId}',
            name: 'FirestoreService',
          );
        }
      }
      
      // Sonuçları tarihe göre sırala
      userResults.sort((a, b) => b.result.timestamp.compareTo(a.result.timestamp));

      return userResults;

    } catch (e, s) {
      developer.log(
        'Kullanıcı sonuçları ve quiz detayları birleştirilirken hata oluştu',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }
}
