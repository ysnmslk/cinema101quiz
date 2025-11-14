
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:myapp/quiz/models/quiz_models.dart' as quiz_models;


import 'package:myapp/quiz/screens/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final dynamic quiz; // Accept both Quiz types
  final bool isCompleted;

  const QuizCard({super.key, required this.quiz, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Köşeleri yuvarlatılmış resim için
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                // Convert quiz_model.Quiz to quiz_models.Quiz if needed
                final quizModelsQuiz = quiz is quiz_models.Quiz 
                    ? quiz 
                    : quiz_models.Quiz(
                        id: quiz.id,
                        title: quiz.title,
                        description: quiz.description,
                        topic: quiz.topic,
                        imageUrl: quiz.imageUrl,
                        durationMinutes: quiz.durationMinutes,
                        createdAt: quiz.createdAt ?? Timestamp.now(),
                      );
                return QuizScreen(quiz: quizModelsQuiz, quizId: quiz.id);
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim ve Tamamlandı ikonu
            Stack(
              children: [
                Hero(
                  tag: quiz.id, // Animasyon için Hero widget'ı
                  child: quiz.imageUrl.isNotEmpty && quiz.imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: quiz.imageUrl,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            debugPrint('Image load error for $url: $error');
                            return Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.grey, size: 50),
                                  SizedBox(height: 4),
                                  Text(
                                    'Resim yüklenemedi',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                          memCacheWidth: 600,
                          memCacheHeight: 400,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          maxWidthDiskCache: 600,
                          maxHeightDiskCache: 400,
                        )
                      : Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                              SizedBox(height: 4),
                              Text(
                                'Resim URL\'si yok',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
                // Eğer quiz tamamlandıysa, sağ üst köşeye bir ikon ekle
                if (isCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            // Başlık ve Açıklama
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    quiz.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12.0),
                  // Etiket ve Süre bilgisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(quiz.topic),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.durationMinutes} dk',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
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
