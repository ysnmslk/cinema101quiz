
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

  Future<void> submitQuizResult(QuizResult result) async {
    await _firestore
        .collection('users')
        .doc(result.userId)
        .collection('solvedQuizzes')
        .add(result.toMap());
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
  
  Future<void> submitResult(QuizResult result) {
    // TODO: implement submitResult
    throw UnimplementedError();
  }
}
