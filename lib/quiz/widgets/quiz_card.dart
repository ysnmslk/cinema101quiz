
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../screens/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  Uint8List _decodeBase64(String base64String) {
    try {
      String pureBase64 = base64String.split(',').last;
      return base64Decode(pureBase64);
    } catch (e) {
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (quiz.imageUrl.startsWith('data:image')) {
      final imageBytes = _decodeBase64(quiz.imageUrl);
      imageWidget = imageBytes.isNotEmpty
          ? Image.memory(
              imageBytes, 
              width: double.infinity,
              fit: BoxFit.cover, 
            )
          : _buildErrorImage();
    } else {
      imageWidget = Image.network(
        quiz.imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(quizId: quiz.id),
            ),
          );
        },
        // --- DEĞİŞİKLİĞİN YAPILDIĞI YER ---
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Sütun yüksekliğini içeriğine göre ayarla
          children: [
            // Resim 16:9 oranını koruyacak
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageWidget,
            ),
            // Metin alanı
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
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

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.quiz_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}
