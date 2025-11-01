
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class QuizIntro extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onStart;

  const QuizIntro({super.key, required this.quiz, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                quiz.imageUrl.isNotEmpty
                  ? Image.network(
                      quiz.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
                    )
                  : Container(color: Colors.blueGrey.shade100, child: const Icon(Icons.image_not_supported, size: 50)),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(178)], // ~70% opacity
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    quiz.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      Chip(label: Text('${quiz.questions.length} Soru')),
                      Chip(label: Text('${quiz.durationMinutes} Dakika')),
                      Chip(label: Text(quiz.topic)),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başla'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
