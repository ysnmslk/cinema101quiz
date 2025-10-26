
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizIntro extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onStartQuiz;

  const QuizIntro({super.key, required this.quiz, required this.onStartQuiz});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              child: Image.network(quiz.imageUrl, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(
              quiz.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              quiz.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onStartQuiz,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Quize Başla'),
            ),
          ],
        ),
      ),
    );
  }
}

