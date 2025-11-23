
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
          // AdMob reklam alanı için boş alan
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Reklam Alanı',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 16),
          Text(
            'Soru ${_currentQuestionIndex + 1} / ${questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Modern balon tasarımında soru
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                Color? bubbleColor;
                Color? textColor;
                Icon? trailingIcon;
                String optionLabel = String.fromCharCode(65 + index); // A, B, C, D

                if (isAnswered) {
                  if (option.isCorrect) {
                    bubbleColor = Colors.green.withOpacity(0.15);
                    textColor = Colors.green.shade700;
                    trailingIcon = Icon(Icons.check_circle, color: Colors.green.shade700, size: 28);
                  } else if (isSelected) {
                    bubbleColor = Colors.red.withOpacity(0.15);
                    textColor = Colors.red.shade700;
                    trailingIcon = Icon(Icons.cancel, color: Colors.red.shade700, size: 28);
                  } else {
                    bubbleColor = Colors.grey.withOpacity(0.1);
                    textColor = Colors.grey.shade700;
                  }
                } else {
                  bubbleColor = isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface;
                  textColor = isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isAnswered ? null : () => _answerQuestion(index, questions),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.3),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Seçenek harfi (A, B, C, D)
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  optionLabel,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.onPrimary
                                        : Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Seçenek metni
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            // İkon (doğru/yanlış)
                            if (trailingIcon != null) ...[
                              const SizedBox(width: 12),
                              trailingIcon,
                            ],
                          ],
                        ),
                      ),
                    ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
