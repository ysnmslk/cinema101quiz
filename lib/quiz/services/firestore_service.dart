
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

    // Ana quiz verisinden bir Quiz nesnesi oluştur
    Quiz quiz = Quiz.fromMap(quizDoc.data()!, quizDoc.id);

    // Ayrı bir koleksiyondan soruları getir
    var questionsSnapshot = await _db
        .collection('quiz_questions')
        .where('quizId', isEqualTo: quizId)
        .get();

    // Soruları Quiz nesnesine ata
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

    // 1. Yeni bir quiz için referans oluştur ve batch'e ekle
    DocumentReference quizRef = _db.collection('quizzes').doc();
    batch.set(quizRef, {
      'title': quiz.title,
      'description': quiz.description,
      'imageUrl': quiz.imageUrl,
    });

    // 2. Her bir soruyu, quiz'in ID'sine referans vererek batch'e ekle
    for (var question in questions) {
      DocumentReference questionRef = _db.collection('quiz_questions').doc();
      batch.set(questionRef, {
        'quizId': quizRef.id,
        'questionText': question.questionText,
        'options': question.options,
        'correctOptionIndex': question.correctOptionIndex,
      });
    }

    // 3. Batch işlemini gerçekleştir
    await batch.commit();
  }
}
