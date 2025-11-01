
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class QuizResults extends StatelessWidget {
  final Quiz quiz;
  final Map<int, int> selectedAnswers;
  final VoidCallback onRetake;

  const QuizResults({
    super.key,
    required this.quiz,
    required this.selectedAnswers,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswers = 0;
    selectedAnswers.forEach((questionIndex, selectedOptionIndex) {
      if (selectedOptionIndex == quiz.questions[questionIndex].correctAnswerIndex) {
        correctAnswers++;
      }
    });

    double scorePercentage = (correctAnswers / quiz.questions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} Sonuçları'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tebrikler!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Puanınız: $correctAnswers / ${quiz.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Başarı: ${scorePercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetake,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Çöz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Ana Ekrana Dön'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            const Text('Cevapların İncelenmesi'),
            Expanded(
              child: ListView.builder(
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  final selectedOptIndex = selectedAnswers[index];
                  final correctOptIndex = question.correctAnswerIndex;
                  final bool isCorrect = selectedOptIndex == correctOptIndex;

                  return Card(
                    color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        isCorrect ? Icons.check_circle : Icons.cancel,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      title: Text(question.text),
                      subtitle: selectedOptIndex != null
                          ? Text('Senin cevabın: ${question.options[selectedOptIndex].text}')
                          : const Text('Cevaplanmadı'),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
