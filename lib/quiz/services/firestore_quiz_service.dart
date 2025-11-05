import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';
import 'package:myapp/quiz/services/quiz_service.dart';

class FirestoreQuizService implements QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Quiz>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Quiz.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Quiz?> getQuizById(String id) async {
    final doc = await _firestore.collection('quizzes').doc(id).get();
    if (!doc.exists) return null;
    return Quiz.fromFirestore(doc);
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').add(quiz.toMap());
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await _firestore.collection('quizzes').doc(id).delete();
  }

  Future<void> submitResult(QuizResult result) async {
    await _firestore.collection('results').add(result.toMap());
  }

  @override
  Future<void> submitQuizResult(QuizResult result) async {
    await _firestore.collection('results').add(result.toMap());
  }
}