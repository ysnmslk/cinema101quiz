
import 'package:mockito/mockito.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';
import 'package:myapp/quiz/services/quiz_service.dart';

class MockAuthService extends Mock implements AuthService {}

class MockQuizService extends Mock implements QuizService {
  @override
  Future<List<Quiz>> getQuizzes() {
    return Future.value([
      Quiz(
        id: '1',
        title: 'Quiz 1',
        description: 'Quiz 1 description',
        topic: 'Topic 1',
        durationMinutes: 10,
        imageUrl: '',
        questions: [
          Question(
            text: 'Question 1',
            options: ['Option 1', 'Option 2'],
            correctAnswerIndex: 0, id: '',
          ),
        ], createdAt: null,
      ),
    ]);
  }

  Future<void> submitResult(QuizResult result) {
    return Future.value();
  }
}
