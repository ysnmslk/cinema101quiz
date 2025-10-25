
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tüm quizlerin temel bilgilerini getirir.
  Future<List<Quiz>> getQuizzes() async {
    var snapshot = await _db.collection('quizzes').get();
    return snapshot.docs
        .map((doc) => Quiz.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Belirli bir quiz'i ve ona ait soruları getirir.
  Future<Quiz?> getQuizById(String quizId) async {
    var quizDoc = await _db.collection('quizzes').doc(quizId).get();
    if (!quizDoc.exists || quizDoc.data() == null) {
      return null;
    }

    Quiz quiz = Quiz.fromMap(quizDoc.data()!, quizDoc.id);

    var questionsSnapshot = await _db
        .collection('quizzes')
        .doc(quizId)
        .collection('questions') // Alt koleksiyon olarak oku
        .get();

    if (questionsSnapshot.docs.isNotEmpty) {
      quiz.questions = questionsSnapshot.docs
          .map((doc) => Question.fromMap(doc.data(), doc.id))
          .toList();
    }

    return quiz;
  }

  /// Yeni bir quiz'i ve ona ait soruları standart toMap metotlarını kullanarak ekler.
  Future<void> addQuizWithQuestions(Quiz quiz, List<Question> questions) async {
    WriteBatch batch = _db.batch();

    // 1. Quiz belgesini oluştur.
    DocumentReference quizRef = _db.collection('quizzes').doc(quiz.id);
    // Standart toMap() metodunu kullan, alan adlarını manuel yazma.
    batch.set(quizRef, quiz.toMap());

    // 2. Her soruyu, quiz'in altında bir alt koleksiyona ekle.
    for (var question in questions) {
      DocumentReference questionRef = quizRef.collection('questions').doc(question.id);
      // Standart question.toMap() metodunu kullan.
      batch.set(questionRef, question.toMap());
    }

    // 3. Tüm işlemleri tek seferde gerçekleştir.
    await batch.commit();
  }
}
