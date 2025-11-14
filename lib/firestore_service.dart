
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
      developer.log('Soruları getiriyor, Quiz ID: $quizId', name: 'FirestoreService');
      
      // Önce quiz document'ini kontrol et - belki sorular direkt burada
      final quizDoc = await _db.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        developer.log('Quiz dokümanı bulunamadı: $quizId', name: 'FirestoreService');
        return [];
      }
      
      final quizData = quizDoc.data()!;
      developer.log('Quiz dokümanı bulundu: $quizId, veri: $quizData', name: 'FirestoreService');
      
      // Subcollection'dan soruları çek
      final snapshot = await _db
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      developer.log('Questions subcollection sorgusu tamamlandı, doküman sayısı: ${snapshot.docs.length}', name: 'FirestoreService');

      if (snapshot.docs.isEmpty) {
        developer.log('Quiz için soru bulunamadı (subcollection boş): $quizId', name: 'FirestoreService');
        
        // Alternatif: Belki sorular quiz document'inde direkt array olarak tutuluyor?
        if (quizData.containsKey('questions') && quizData['questions'] is List) {
          developer.log('Quiz dokümanında questions array bulundu, parse ediliyor...', name: 'FirestoreService');
          final questionsList = quizData['questions'] as List<dynamic>;
          final questions = <Question>[];
          for (var i = 0; i < questionsList.length; i++) {
            try {
              final qData = questionsList[i] as Map<String, dynamic>;
              final question = Question.fromFirestore('q_$i', qData);
              if (question.options.isNotEmpty) {
                questions.add(question);
              }
            } catch (e) {
              developer.log('Quiz dokümanındaki soru parse edilemedi: $i', name: 'FirestoreService', error: e);
            }
          }
          if (questions.isNotEmpty) {
            developer.log('${questions.length} soru quiz dokümanından yüklendi', name: 'FirestoreService');
            return questions;
          }
        }
        
        return [];
      }

      final questions = <Question>[];
      for (final doc in snapshot.docs) {
        try {
          final docData = doc.data();
          // Debug: Ham veriyi logla
          developer.log('Soru dokümanı: ${doc.id}, veri: $docData', name: 'FirestoreService');
          
          final question = Question.fromFirestore(doc.id, docData);
          developer.log('Parse edilen soru: ${question.text}, options sayısı: ${question.options.length}', name: 'FirestoreService');
          
          if (question.options.isNotEmpty) {
            questions.add(question);
          } else {
            developer.log('Soru parse edilemedi (boş options): ${doc.id}, ham veri: $docData', name: 'FirestoreService');
          }
        } catch (e, s) {
          developer.log('Soru parse hatası: ${doc.id}', name: 'FirestoreService', error: e, stackTrace: s);
          // Hatalı soruyu atla, diğerlerini yükle
        }
      }

      developer.log('${questions.length} soru yüklendi (toplam: ${snapshot.docs.length})', name: 'FirestoreService');
      return questions;
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

  Stream<Set<String>> getCompletedQuizzesStream(String userId) {
    return _db
        .collection('1users') 
        .doc(userId)
        .collection('results')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> saveUserResult(String userId, String quizId, int score, int totalQuestions) async {
    try {
      final resultData = {
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'completedAt': Timestamp.now(),
      };

      await _db
          .collection('1users') 
          .doc(userId)
          .collection('results')
          .doc(quizId)
          .set(resultData, SetOptions(merge: true));
    } catch (e, s) {
      developer.log('Kullanıcı sonucunu kaydederken hata', name: 'FirestoreService', error: e, stackTrace: s);
      rethrow;
    }
  }
  
  Stream<List<QuizResultDetails>> getUserResultsWithDetailsStream(String userId) {
    final resultsStream = _db
        .collection('1users') 
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
