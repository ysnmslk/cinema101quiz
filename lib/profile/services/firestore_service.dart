
import 'package:myapp/profile/models/solved_quiz.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

abstract class FirestoreService {
  Stream<List<SolvedQuiz>> getSolvedQuizzes(String userId);
  Future<Map<String, dynamic>> getUserStats(String userId);
  Stream<List<QuizResultDetails>> getUserResultsWithDetailsStream(String userId);
  Future<bool> isAdmin(String userId);
}
