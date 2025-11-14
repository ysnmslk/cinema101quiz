
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/firestore_service.dart';
import 'package:myapp/quiz/models/quiz_models.dart';
import 'package:myapp/quiz/widgets/quiz_results.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz, required String quizId});

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
    try {
      final questions = await context.read<FirestoreService>().getQuestionsForQuiz(widget.quiz.id);
      if (questions.isEmpty) {
        // ignore: avoid_print
        print('Uyarı: Quiz için soru bulunamadı: ${widget.quiz.id}');
        return [];
      }
      // Soru sayısı kadar null içeren bir liste oluştur
      _selectedAnswers = List.generate(questions.length, (_) => null);
      // Soruları karıştır
      questions.shuffle();
      return questions;
    } catch (e) {
      // ignore: avoid_print
      print('Soruları yüklerken hata: $e');
      return [];
    }
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

      // Son soru değilse otomatik olarak sonraki soruya geç
      final isLastQuestion = _currentQuestionIndex == questions.length - 1;
      if (!isLastQuestion) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _currentQuestionIndex++;
            });
          }
        });
      }
      // Son soruysa otomatik geçiş yapma, kullanıcı "Quiz'i Bitir" butonuna tıklayacak
    }
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _showResults(List<Question> questions) async {
    final userId = context.read<AuthService>().currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await context.read<FirestoreService>().saveUserResult(
            userId,
            widget.quiz.id,
            _score,
            questions.length,
          );
    }
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quiz: widget.quiz,
          score: _score,
          totalQuestions: questions.length,
          questions: questions,
          selectedAnswers: _selectedAnswers,
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
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Hata: ${snapshot.error}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Lütfen tekrar deneyin'),
                ],
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Soru bulunamadı', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Quiz ID: ${widget.quiz.id}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
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
    final bool isLastQuestion = _currentQuestionIndex == questions.length - 1;

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
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                question.text,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
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
                    tileColor = Colors.green.withAlpha(75);
                    trailingIcon = const Icon(Icons.check, color: Colors.green);
                  } else if (isSelected) {
                    tileColor = Colors.red.withAlpha(75);
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
          // Son soru ve cevap verildiyse "Quiz'i Bitir" butonu göster
          if (isLastQuestion && isAnswered)
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Quiz\'i Bitir'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showResults(questions),
            )
          else if (isLastQuestion && !isAnswered)
            const SizedBox(height: 20), // Son soruya cevap verilmediyse boşluk bırak
        ],
      ),
    );
  }
}
