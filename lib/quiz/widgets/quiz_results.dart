
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class QuizResults extends StatelessWidget {
  final Quiz quiz;
  final int score;
  final List<int> userAnswers;
  final VoidCallback onRestartQuiz;

  const QuizResults({
    super.key,
    required this.quiz,
    required this.score,
    required this.userAnswers,
    required this.onRestartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = quiz.questions.length;
    final double percentage = (score / totalQuestions) * 100;

    String getResultMessage() {
      if (percentage >= 80) {
        return "Harika İş! Sinema dahisisin!";
      } else if (percentage >= 50) {
        return "İyi iş! Gelişiyorsun!";
      } else {
        return "Biraz daha pratik yapmaya ne dersin?";
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quiz Bitti!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(getResultMessage(), style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Sonucun: $score/$totalQuestions', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            Text('Başarı Oranı: ${percentage.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: onRestartQuiz, child: const Text('Tekrar Dene')),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ana Menüye Dön')),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Text("Cevapların", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalQuestions,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                final userAnswerIndex = userAnswers[index];
                final isCorrect = userAnswerIndex == question.correctOptionIndex;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soru ${index + 1}: ${question.questionText}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Senin Cevabın: ${question.options[userAnswerIndex]}',
                          style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
                        ),
                        if (!isCorrect)
                          Text(
                            'Doğru Cevap: ${question.options[question.correctOptionIndex]}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        const SizedBox(height: 5),
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
