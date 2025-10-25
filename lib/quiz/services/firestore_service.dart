
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/question_model.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tüm quizlerin temel bilgilerini (sorular hariç) getirir.
  Future<List<Quiz>> getQuizzes() async {
    var snapshot = await _db.collection('quizzes').get();
    return snapshot.docs
        .map((doc) => Quiz.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Belirli bir quiz'i ID'sine göre, sorularıyla birlikte getirir.
  Future<Quiz?> getQuizById(String quizId) async {
    var quizDoc = await _db.collection('quizzes').doc(quizId).get();
    if (!quizDoc.exists || quizDoc.data() == null) {
      return null;
    }

    Quiz quiz = Quiz.fromMap(quizDoc.data()!, quizDoc.id);

    var questionsSnapshot = await _db
        .collection('quiz_questions')
        .where('quizId', isEqualTo: quizId)
        .get();

    if (questionsSnapshot.docs.isNotEmpty) {
      quiz.questions = questionsSnapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
    }

    return quiz;
  }

  /// Yeni bir quiz'i ve ona ait soruları bir WriteBatch işlemiyle Firestore'a ekler.
  Future<void> addQuizWithQuestions(Quiz quiz, List<Question> questions) async {
    WriteBatch batch = _db.batch();

    // 1. Yeni bir quiz belgesi için referans oluştur ve ana bilgileri batch'e ekle
    DocumentReference quizRef = _db.collection('quizzes').doc(quiz.id);
    batch.set(quizRef, {
      'id': quiz.id,
      'title': quiz.title,
      'description': quiz.description,
      'imageUrl': quiz.imageUrl,
      'category': quiz.category,
      'durationMinutes': quiz.durationMinutes,
      'totalQuestions': quiz.totalQuestions,
      // Not: totalquestion alanı eski veriyle uyum için eklenebilir ama yeni standart totalQuestions olmalı
      'totalquestion': quiz.totalQuestions, 
    });

    // 2. Her bir soruyu, quiz'in ID'sine referans vererek ayrı bir koleksiyona ekle
    for (var question in questions) {
      DocumentReference questionRef = _db.collection('quiz_questions').doc(question.id);
      batch.set(questionRef, {
        'id': question.id,
        'quizId': quizRef.id, // Oluşturulan quiz'in ID'sini referans olarak ata
        'questionText': question.questionText,
        'options': question.options,
        'correctOptionIndex': question.correctOptionIndex,
      });
    }

    // 3. Tüm işlemleri tek seferde gerçekleştir
    await batch.commit();
  }
}
