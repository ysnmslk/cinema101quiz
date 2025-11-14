import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/services/auth_service.dart';
import '../quiz/models/quiz_model.dart';
import '../quiz/models/quiz_result.dart';
import '../quiz/services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final List<int> _selectedAnswers = [];
  late Future<Quiz> _quizFuture;

  @override
  void initState() {
    super.initState();
    _quizFuture = _loadQuiz();
  }

  Future<Quiz> _loadQuiz() async {
    final quizService = Provider.of<QuizService>(context, listen: false);
    final quiz = await quizService.getQuizById(widget.quizId);
    if (quiz == null) {
      throw Exception('Quiz not found');
    }
    return quiz;
  }

  void _nextQuestion(int selectedOptionIndex) async {
    final quiz = await _quizFuture;
    setState(() {
      _selectedAnswers.add(selectedOptionIndex);
      if (_currentQuestionIndex < quiz.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        // Submit results
        _submitResults();
      }
    });
  }

  Future<void> _submitResults() async {
    final quiz = await _quizFuture;
    final quizService = Provider.of<QuizService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    if (user == null) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hata'),
          content: const Text('Lütfen giriş yapın.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_selectedAnswers[i] == quiz.questions[i].correctAnswerIndex) {
        score++;
      }
    }

    final result = QuizResult(
      quizId: widget.quizId,
      userId: user.uid,
      score: score,
      totalQuestions: quiz.questions.length,
      dateCompleted: DateTime.now(),
      answers: _selectedAnswers,
      timestamp: DateTime.now(),
    );

    await quizService.submitQuizResult(result, quiz);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Finished'),
        content: Text('Your score: $score / ${quiz.questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quiz>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        final quiz = snapshot.data!;
        final question = quiz.questions[_currentQuestionIndex];
        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of ${quiz.questions.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(question.text, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 32),
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = _selectedAnswers.length > _currentQuestionIndex 
                      ? _selectedAnswers[_currentQuestionIndex] == index 
                      : false;
                  return InkWell(
                    onTap: () => _nextQuestion(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Theme.of(context).colorScheme.primary : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Text(option)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}