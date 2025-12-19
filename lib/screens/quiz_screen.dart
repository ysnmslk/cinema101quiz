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
        final isSelected = _selectedAnswers.length > _currentQuestionIndex;
        final selectedIndex = isSelected ? _selectedAnswers[_currentQuestionIndex] : null;
        
        // Ekran genişliğini kontrol et (1200px üzeri = büyük ekran/desktop)
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 1200;
        final adWidth = 200.0; // Kenar reklam genişliği
        
        return Scaffold(
          appBar: AppBar(
            title: Text(quiz.title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: isLargeScreen
              ? Row(
                  children: [
                    // Sol reklam alanı
                    Container(
                      width: adWidth,
                      color: Colors.grey[100],
                      child: Center(
                        child: Text(
                          'Reklam\nAlanı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // Ortada quiz içeriği
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 800,
                            maxHeight: double.infinity,
                          ),
                          child: _buildQuizContent(context, quiz, question, selectedIndex),
                        ),
                      ),
                    ),
                    // Sağ reklam alanı
                    Container(
                      width: adWidth,
                      color: Colors.grey[100],
                      child: Center(
                        child: Text(
                          'Reklam\nAlanı',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : _buildQuizContent(context, quiz, question, selectedIndex),
        );
      },
    );
  }

  Widget _buildQuizContent(BuildContext context, Quiz quiz, Question question, int? selectedIndex) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                // AdMob reklam alanı için boş alan
                const SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Reklam Alanı',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / quiz.questions.length,
                  backgroundColor: Colors.grey[300],
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 12),
                // Soru numarası
                Text(
                  'Soru ${_currentQuestionIndex + 1} / ${quiz.questions.length}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Modern balon tasarımında soru
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        question.text,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Modern şık tasarımları
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isOptionSelected = selectedIndex == index;
                      Color? bubbleColor;
                      Color? textColor;
                      String optionLabel = String.fromCharCode(65 + index); // A, B, C, D

                      if (isOptionSelected) {
                        bubbleColor = Theme.of(context).colorScheme.primaryContainer;
                        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
                      } else {
                        bubbleColor = Theme.of(context).colorScheme.surface;
                        textColor = Theme.of(context).colorScheme.onSurface;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _nextQuestion(index),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isOptionSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.withOpacity(0.3),
                                  width: isOptionSelected ? 2 : 1.5,
                                ),
                                boxShadow: isOptionSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // Seçenek harfi (A, B, C, D)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isOptionSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        optionLabel,
                                        style: TextStyle(
                                          color: isOptionSelected
                                              ? Theme.of(context).colorScheme.onPrimary
                                              : Theme.of(context).colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Seçenek metni
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}