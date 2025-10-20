
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/screens/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  // Base64 string'ini Uint8List'e çeviren yardımcı fonksiyon
  Uint8List _decodeBase64(String base64String) {
    try {
      // "data:image/jpeg;base64," gibi başlıkları temizle
      String pureBase64 = base64String.split(',').last;
      return base64Decode(pureBase64);
    } catch (e) {
      print("Base64 decode hatası: $e");
      return Uint8List(0); // Hata durumunda boş liste döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (quiz.imageUrl.startsWith('data:image')) {
      final imageBytes = _decodeBase64(quiz.imageUrl);
      if (imageBytes.isNotEmpty) {
        imageWidget = Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        );
      } else {
        // Decode hatası olursa yer tutucu göster
        imageWidget = Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      }
    } else {
      // Normal URL ise Image.network kullan
      imageWidget = Image.network(
        quiz.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Icon(Icons.error_outline, size: 50, color: Colors.grey),
          );
        },
      );
    }

    return SizedBox( // ListView içinde unbounded height hatasını önlemek için
      height: 280,
      child: Card(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Expanded yerine belirli bir yükseklik ver
              SizedBox(
                height: 180,
                child: imageWidget, // Dinamik olarak oluşturulan image widget'ı kullan
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      quiz.description,
                      style: TextStyle(
                        fontSize: 14.0,
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
      ),
    );
  }
}
