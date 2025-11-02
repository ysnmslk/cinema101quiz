
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/firestore_service.dart';
import 'package:myapp/quiz/models/quiz_models.dart';
import 'package:myapp/quiz/widgets/quiz_results.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  int _score = 0;
  late List<int?> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  Future<List<Question>> _loadQuestions() async {
    final questions = await context.read<FirestoreService>().getQuestionsForQuiz(widget.quiz.id);
    // Soru sayısı kadar null içeren bir liste oluştur
    _selectedAnswers = List.generate(questions.length, (_) => null);
    // Soruları karıştır
    questions.shuffle();
    return questions;
  }

  void _answerQuestion(int selectedOptionIndex, List<Question> questions) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      final question = questions[_currentQuestionIndex];
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = selectedOptionIndex;
        if (question.options[selectedOptionIndex].isCorrect) {
          _score++;
        }
      });

      // Kısa bir gecikmeden sonra otomatik olarak sonraki soruya geç
      Future.delayed(const Duration(milliseconds: 800), () {
        _nextQuestion(questions.length);
      });
    }
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() async {
    final userId = context.read<AuthService>().currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await context.read<FirestoreService>().saveUserResult(
            userId,
            widget.quiz.id,
            _score,
            widget.quiz.questions!.length,
          );
    }
    
    // Düzeltme: `mounted` kontrolü eklendi.
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quiz: widget.quiz,
          score: _score,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(snapshot.hasError ? 'Hata: ${snapshot.error}' : 'Soru bulunamadı.'));
          }

          final questions = snapshot.data!;
          return _buildQuizBody(questions);
        },
      ),
    );
  }

  Widget _buildQuizBody(List<Question> questions) {
    final question = questions[_currentQuestionIndex];
    final bool isAnswered = _selectedAnswers[_currentQuestionIndex] != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Soru ${_currentQuestionIndex + 1} / ${questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            question.text,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                Color? tileColor;
                Icon? trailingIcon;

                if (isAnswered) {
                  if (option.isCorrect) {
                    // Düzeltme: `withOpacity` yerine `withAlpha` kullanıldı.
                    tileColor = Colors.green.withAlpha(75); // ~30% opacity
                    trailingIcon = const Icon(Icons.check, color: Colors.green);
                  } else if (isSelected) {
                    // Düzeltme: `withOpacity` yerine `withAlpha` kullanıldı.
                    tileColor = Colors.red.withAlpha(75); // ~30% opacity
                    trailingIcon = const Icon(Icons.close, color: Colors.red);
                  }
                }

                return Card(
                  color: tileColor,
                  child: ListTile(
                    title: Text(option.text),
                    onTap: isAnswered ? null : () => _answerQuestion(index, questions),
                    trailing: trailingIcon,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
