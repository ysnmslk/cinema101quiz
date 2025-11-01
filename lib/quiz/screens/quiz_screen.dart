
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // EKLENDİ: Timestamp için gerekli
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/quiz/widgets/question_display.dart';
import 'package:myapp/quiz/widgets/quiz_results.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  late Future<Quiz?> _quizFuture;

  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
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
    final quiz = await _quizFuture;

    if (user == null || quiz == null) return;

    int correctAnswers = 0;
    _selectedAnswers.forEach((questionIndex, selectedOptionIndex) {
      if (selectedOptionIndex == quiz.questions[questionIndex].correctAnswerIndex) {
        correctAnswers++;
      }
    });

    final result = UserQuizResult(
      quizId: quiz.id,
      score: ((correctAnswers / quiz.questions.length) * 100).round(), // DÜZELTİLDİ: .round() eklendi
      correctAnswers: correctAnswers,
      totalQuestions: quiz.questions.length,
      dateCompleted: Timestamp.now(), // DÜZELTİLDİ: DateTime.now() -> Timestamp.now()
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
    return FutureBuilder<Quiz?>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Hata: ${snapshot.error}')));
        }
        if (!snapshot.hasData || snapshot.data == null) { 
          return const Scaffold(body: Center(child: Text('Quiz bulunamadı.')));
        }

        final quiz = snapshot.data!;

        if (_isFinished) {
          return Scaffold(
            appBar: AppBar(title: Text('${quiz.title} Sonuçları')),
            body: QuizResults(
              quiz: quiz,
              selectedAnswers: _selectedAnswers,
              onRetake: () {
                setState(() {
                  _isFinished = false;
                  _currentQuestionIndex = 0;
                  _selectedAnswers.clear();
                });
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: QuestionDisplay(
                    question: quiz.questions[_currentQuestionIndex],
                    selectedOptionIndex: _selectedAnswers[_currentQuestionIndex],
                    onAnswerSelected: (optionIndex) {
                      _onAnswerSelected(_currentQuestionIndex, optionIndex);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentQuestionIndex > 0)
                      ElevatedButton(onPressed: _goToPreviousQuestion, child: const Text('Önceki')),
                    const Spacer(),
                    if (_currentQuestionIndex < quiz.questions.length - 1)
                      ElevatedButton(onPressed: _goToNextQuestion, child: const Text('Sonraki')),
                    if (_currentQuestionIndex == quiz.questions.length - 1)
                      ElevatedButton(
                        onPressed: _submitQuiz, 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Testi Bitir'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
