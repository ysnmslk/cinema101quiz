
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/question_model.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Quiz>> getQuizzes() async {
    var snapshot = await _db.collection('quizzes').get();
    return snapshot.docs.map((doc) => Quiz.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Quiz?> getQuizById(String quizId) async {
    // 1. Quiz'in ana belgesini al
    var quizDoc = await _db.collection('quizzes').doc(quizId).get();
    if (!quizDoc.exists) {
      return null;
    }

    // 2. Quiz'e ait soruları al
    var questionsSnapshot = await _db
        .collection('quiz_questions')
        .where('quizId', isEqualTo: quizId)
        .get();

    List<Question> questions = questionsSnapshot.docs
        .map((doc) => Question.fromMap(doc.data(), doc.id))
        .toList();

    // 3. Soruları içeren tam bir Quiz nesnesi oluştur
    return Quiz(
      id: quizDoc.id,
      title: quizDoc.data()!['title'] ?? '',
      description: quizDoc.data()!['description'] ?? '',
      imageUrl: quizDoc.data()!['imageUrl'] ?? '',
      questions: questions, // Soruları buraya ekliyoruz
    );
  }
}
