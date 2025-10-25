
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

  // --- YENİ VE DOĞRU METOT --- //
  /// Yeni bir quiz'i ve ona ait soruları Firestore'a ekler.
  /// ID'leri otomatik olarak oluşturur.
  Future<void> addQuiz(Quiz quiz) async {
    WriteBatch batch = _db.batch();

    // 1. Ana quiz belgesi için yeni bir ID oluştur.
    DocumentReference quizRef = _db.collection('quizzes').doc(); // Otomatik ID
    
    // Quiz nesnesinin toMap() metodunu kullanarak veriyi hazırla.
    // Bu metot, question.length'i kullanarak totalQuestions'ı otomatik olarak ayarlar.
    batch.set(quizRef, quiz.toMap());

    // 2. Her bir soruyu, yeni oluşturulan quiz'in altındaki 'questions' koleksiyonuna ekle.
    for (var question in quiz.questions) {
       // Her soru için yeni bir ID oluştur.
      DocumentReference questionRef = quizRef.collection('questions').doc(); // Otomatik ID
      batch.set(questionRef, question.toMap());
    }

    // 3. Tüm işlemleri tek bir atomik operasyonla Firestore'a gönder.
    await batch.commit();
  }
}
