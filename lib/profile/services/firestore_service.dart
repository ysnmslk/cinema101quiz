
import 'package:myapp/profile/models/solved_quiz.dart';

abstract class FirestoreService {
  Stream<List<SolvedQuiz>> getSolvedQuizzes(String userId);
  Future<Map<String, dynamic>> getUserStats(String userId);
}
