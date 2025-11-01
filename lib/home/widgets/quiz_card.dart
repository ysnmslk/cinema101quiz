
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/screens/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final bool isCompleted;
  final bool isNew;

  const QuizCard({
    super.key,
    required this.quiz,
    this.isCompleted = false,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Tıklama olayını QuizScreen'e yönlendir
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QuizScreen(quizId: quiz.id),
            ),
          );
        },
        child: Stack(
          children: [
            // --- Ana içerik ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resim alanı
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    color: Colors.blueGrey.shade100,
                    child: quiz.imageUrl.isNotEmpty
                        ? Image.network(
                            quiz.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          )
                        : Icon(
                            Icons.quiz_rounded,
                            size: 50,
                            color: colorScheme.primary.withAlpha(128), // withOpacity -> withAlpha
                          ),
                  ),
                ),
                // Metin alanı
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          quiz.title,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quiz.description,
                          style: textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- Çözüldü Katmanı ---
            if (isCompleted)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(128), // withOpacity -> withAlpha
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'ÇÖZÜLDÜ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),

            // --- Yeni Etiketi ---
            if (isNew && !isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(76), blurRadius: 4, offset: const Offset(1, 1))]
                  ),
                  child: const Text(
                    'YENİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
