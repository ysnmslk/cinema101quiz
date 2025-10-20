
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/quiz/widgets/question_display.dart';
import 'package:myapp/quiz/widgets/quiz_intro.dart';
import 'package:myapp/quiz/widgets/quiz_results.dart';

enum QuizState { loading, intro, question, results }

class QuizScreen extends StatefulWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Quiz? _quiz;
  QuizState _quizState = QuizState.loading;
  int _currentQuestionIndex = 0;
  final List<int> _userAnswers = [];
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final quiz = await _firestoreService.getQuizById(widget.quizId);
    if (!mounted) return; 

    if (quiz != null) {
      setState(() {
        _quiz = quiz;
        _quizState = QuizState.intro;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz yüklenemedi!')),
      );
      Navigator.of(context).pop();
    }
  }

  void _startQuiz() {
    setState(() {
      _quizState = QuizState.question;
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _isAnswered = false;
      _selectedAnswerIndex = null;
    });
  }

  void _answerQuestion(int selectedOptionIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = selectedOptionIndex;
      _isAnswered = true;
    });

    _userAnswers.add(selectedOptionIndex);

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isAnswered = false;
        _selectedAnswerIndex = null;
        if (_currentQuestionIndex < _quiz!.questions.length - 1) {
          _currentQuestionIndex++;
        } else {
          _quizState = QuizState.results;
        }
      });
    });
  }

  void _restartQuiz() {
    _startQuiz();
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < _quiz!.questions.length; i++) {
      if (_userAnswers.length > i && _userAnswers[i] == _quiz!.questions[i].correctOptionIndex) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz?.title ?? 'Quiz Yükleniyor...'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: _quizState == QuizState.question && _quiz != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quiz!.questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_quiz == null || _quizState == QuizState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_quizState) {
      case QuizState.intro:
        return QuizIntro(quiz: _quiz!, onStartQuiz: _startQuiz);
      case QuizState.question:
        return QuestionDisplay(
          key: ValueKey<int>(_currentQuestionIndex),
          question: _quiz!.questions[_currentQuestionIndex],
          currentQuestionIndex: _currentQuestionIndex,
          totalQuestions: _quiz!.questions.length,
          onAnswerSelected: _answerQuestion,
          isAnswered: _isAnswered,
          selectedAnswerIndex: _selectedAnswerIndex,
        );
      case QuizState.results:
        return QuizResults(
          quiz: _quiz!,
          score: _calculateScore(),
          userAnswers: _userAnswers,
          onRestartQuiz: _restartQuiz,
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }
}
