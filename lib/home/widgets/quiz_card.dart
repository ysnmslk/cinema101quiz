
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          // Quiz detay sayfasına git
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.quiz_outlined),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
