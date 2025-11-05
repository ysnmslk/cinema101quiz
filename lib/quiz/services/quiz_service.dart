
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';

abstract class QuizService {
  Stream<List<Quiz>> getQuizzes();
  Future<Quiz?> getQuizById(String id);
  Future<void> addQuiz(Quiz quiz);
  Future<void> updateQuiz(Quiz quiz);
  Future<void> deleteQuiz(String id);
  Future<void> submitQuizResult(QuizResult result);
}
