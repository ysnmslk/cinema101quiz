
import 'package:flutter/material.dart';
// Tüm modellerin tek bir merkezi dosyadan geldiğinden emin oluyoruz.
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
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    String getResultMessage() {
      if (percentage >= 80) {
        return "Harika İş! Sinema dahisisin!";
      } else if (percentage >= 50) {
        return "İyi iş! Gelişiyorsun!";
      } else {
        return "Biraz daha pratik yapmaya ne dersin?";
      }
    }

    return SingleChildScrollView(
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
              final userAnswerIndex = userAnswers.length > index ? userAnswers[index] : -1; // Güvenlik kontrolü
              final correctIndex = question.correctAnswerIndex; // --- ALAN ADI GÜNCELLENDİ ---
              final bool isCorrect = userAnswerIndex == correctIndex;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // --- ALAN ADI GÜNCELLENDİ ---
                        'Soru ${index + 1}: ${question.text}', // 'questionText' yerine 'text'
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (userAnswerIndex != -1)
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'Senin Cevabın: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              // --- OPTION KULLANIMI GÜNCELLENDİ ---
                              TextSpan(
                                text: question.options[userAnswerIndex].text, // Option nesnesinin metni
                                style: TextStyle(color: isCorrect ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (!isCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'Doğru Cevap: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                // --- OPTION KULLANIMI GÜNCELLENDİ ---
                                TextSpan(
                                  text: question.options[correctIndex].text, // Option nesnesinin metni
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
