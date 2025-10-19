
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/question_model.dart';

class FirestoreService {
  // Firestore'un ana örneğine erişim
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// <summary>
  /// Firestore'daki 'quizzes' koleksiyonunda bulunan tüm sınavları getirir.
  /// </summary>
  /// <returns>Quiz nesnelerinden oluşan bir liste döndürür.</returns>
  Future<List<Quiz>> getQuizzes() async {
    try {
      // 'quizzes' koleksiyonundan anlık bir görüntü (snapshot) alıyoruz.
      QuerySnapshot snapshot = await _db.collection('quizzes').get();

      // Gelen her bir belgeyi (document) Quiz nesnesine dönüştürüp bir liste oluşturuyoruz.
      List<Quiz> quizzes = snapshot.docs.map((doc) {
        // Belge verilerini ve belge ID'sini kullanarak Quiz nesnesi oluşturuyoruz.
        return Quiz.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      return quizzes;
    } catch (e) {
      print('Hata: Sınavlar getirilemedi! $e');
      // Hata durumunda boş bir liste döndürüyoruz.
      return [];
    }
  }

  
  Future<List<Question>> getQuestionsForQuiz(String quizId) async {
    try {
      // 'quiz_questions' koleksiyonunu 'quiz_id' alanına göre filtreliyoruz.
      QuerySnapshot snapshot = await _db
          .collection('quiz_questions')
          .where('quiz_id', isEqualTo: quizId)
          .get();

      // Gelen belgeleri Question nesnelerine dönüştürüyoruz.
      List<Question> questions = snapshot.docs.map((doc) {
        return Question.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      return questions;
    } catch (e) {
      print('Hata: Sorular getirilemedi! (Quiz ID: $quizId) $e');
      return [];
    }
  }
}
