
import 'package:flutter/material.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/widgets/question_display.dart';
import 'package:myapp/quiz/widgets/quiz_results.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late Future<Quiz> _quizFuture;

  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // Soru index -> Seçilen option index
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _quizFuture = _firestoreService.getQuizById(widget.quizId);
  }

  void _onAnswerSelected(int questionIndex, int optionIndex) {
    setState(() {
      _selectedAnswers[questionIndex] = optionIndex;
    });
  }

  void _submitQuiz() async {
    final user = _authService.currentUser;
    if (user == null) return; // Kullanıcı yoksa çık

    final quiz = await _quizFuture;
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_selectedAnswers.containsKey(i)) {
        final selectedOptionIndex = _selectedAnswers[i]!;
        // Doğru cevabı `correctAnswerIndex` ile kontrol et
        if (selectedOptionIndex == quiz.questions[i].correctAnswerIndex) {
          score++;
        }
      }
    }

    final result = UserQuizResult(
      quizId: quiz.id,
      score: score,
      totalQuestions: quiz.questions.length,
      dateCompleted: Timestamp.now(),
    );

    await _firestoreService.saveQuizResult(user.uid, result);
    await _firestoreService.markQuizAsCompleted(user.uid, quiz.id);

    setState(() {
      _isFinished = true;
    });
  }

  void _goToNextQuestion() {
    setState(() {
      _currentQuestionIndex++;
    });
  }

  void _goToPreviousQuestion() {
    setState(() {
      _currentQuestionIndex--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quiz>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Hata: ${snapshot.error}')));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Quiz bulunamadı.')));
        }

        final quiz = snapshot.data!;

        if (_isFinished) {
          return QuizResults(
            quiz: quiz,
            selectedAnswers: _selectedAnswers,
            onRetake: () {
              setState(() {
                _isFinished = false;
                _currentQuestionIndex = 0;
                _selectedAnswers.clear();
              });
            },
          );
        }

        final question = quiz.questions[_currentQuestionIndex];
        final isLastQuestion = _currentQuestionIndex == quiz.questions.length - 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / quiz.questions.length,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: QuestionDisplay(
              question: question,
              selectedOptionIndex: _selectedAnswers[_currentQuestionIndex],
              onAnswerSelected: (optionIndex) {
                _onAnswerSelected(_currentQuestionIndex, optionIndex);
              },
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentQuestionIndex > 0)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Önceki'),
                      onPressed: _goToPreviousQuestion,
                    ),
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: Icon(isLastQuestion ? Icons.check_circle : Icons.arrow_forward),
                    label: Text(isLastQuestion ? 'Bitir' : 'Sonraki'),
                    onPressed: _selectedAnswers.containsKey(_currentQuestionIndex)
                        ? (isLastQuestion ? _submitQuiz : _goToNextQuestion)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
