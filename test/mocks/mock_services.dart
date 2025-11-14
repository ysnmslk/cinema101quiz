
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result.dart';
import 'package:myapp/quiz/services/quiz_service.dart';

class MockAuthService implements AuthService {
  @override
  Stream<User?> get userStream => Stream.value(null);
  
  @override
  User? get currentUser => null;
  
  @override
  Future<User?> signInAnonymously() async => null;
  
  @override
  Future<User?> signInWithGoogle() async => null;
  
  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async => null;
  
  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async => null;
  
  @override
  Future<void> signOut() async {}
}

class MockQuizService implements QuizService {
  @override
  Stream<List<Quiz>> getQuizzes() {
    return Stream.value([
      Quiz(
        id: '1',
        title: 'Quiz 1',
        description: 'Quiz 1 description',
        topic: 'Topic 1',
        durationMinutes: 10,
        imageUrl: '',
        questions: [
          Question(
            id: 'q1',
            text: 'Question 1',
            options: ['Option 1', 'Option 2'],
            correctAnswerIndex: 0,
          ),
        ],
        createdAt: null,
      ),
    ]);
  }

  @override
  Future<Quiz?> getQuizById(String id) async {
    return null;
  }

  @override
  Future<void> addQuiz(Quiz quiz) async {}

  @override
  Future<void> updateQuiz(Quiz quiz) async {}

  @override
  Future<void> deleteQuiz(String id) async {}

  @override
  Future<void> submitQuizResult(QuizResult result, Quiz quiz) async {}
}
