
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class QuizScreen extends StatelessWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Chip(avatar: const Icon(Icons.timer_outlined), label: Text('${quiz.durationMinutes} dakika')),
                  Chip(avatar: const Icon(Icons.help_outline), label: Text('${quiz.durationMinutes} soru')),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Soru sorma ekranına yönlendirme eklenecek
                  print('Quiz başlıyor: ${quiz.title}');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Quize Başla'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
