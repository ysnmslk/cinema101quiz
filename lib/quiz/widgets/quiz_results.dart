
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final int score;
  final int totalQuestions;
  final List<Question>? questions;
  final List<int?>? selectedAnswers;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.totalQuestions,
    this.questions,
    this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} Sonucu'),
        automaticallyImplyLeading: false, // Geri tuşunu kaldır
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Skor gösterimi
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Tebrikler!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Quiz'i tamamladın.",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: percentage / 100,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                        ),
                        Center(
                          child: Text(
                            '%${percentage.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    totalQuestions > 0 
                      ? '$totalQuestions sorudan $score tanesini doğru bildin.'
                      : 'Skor hesaplanamadı (soru yok).',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Sorular ve cevaplar varsa göster
            if (questions != null && questions!.isNotEmpty && selectedAnswers != null)
              Column(
                children: [
                  Text(
                    'Cevaplar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAnswersList(context, questions!, selectedAnswers!),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersList(BuildContext context, List<Question> questions, List<int?> selectedAnswers) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        final selectedIndex = selectedAnswers[index];
        final isCorrect = selectedIndex != null && 
            question.options[selectedIndex].isCorrect;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Soru ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                ...question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final option = entry.value;
                  final isSelected = selectedIndex == optionIndex;
                  final isCorrectOption = option.isCorrect;

                  Color? backgroundColor;
                  Icon? icon;
                  
                  if (isCorrectOption) {
                    backgroundColor = Colors.green.withAlpha(50);
                    icon = const Icon(Icons.check, color: Colors.green, size: 20);
                  } else if (isSelected && !isCorrectOption) {
                    backgroundColor = Colors.red.withAlpha(50);
                    icon = const Icon(Icons.close, color: Colors.red, size: 20);
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? (isCorrectOption ? Colors.green : Colors.red)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null) ...[
                          icon,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            option.text,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
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
