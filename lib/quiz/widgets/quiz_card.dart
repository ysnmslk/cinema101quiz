
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../screens/quiz_screen.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;

  const QuizCard({super.key, required this.quiz});

  // Base64 string'ini çözümlemek için yardımcı fonksiyon
  Uint8List _decodeBase64(String base64String) {
    try {
      // URI'nin başındaki "data:image/...;base64," kısmını ayıkla
      String pureBase64 = base64String.split(',').last;
      return base64Decode(pureBase64);
    } catch (e) {
      // Hata durumunda boş byte listesi döndür
      return Uint8List(0);
    }
  }

  // Hata veya geçersiz URL durumunda gösterilecek varsayılan widget
  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.quiz_outlined, // Tematik bir ikon
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    // Daha güvenli bir URL ayrıştırma yöntemi kullan
    final uri = Uri.tryParse(quiz.imageUrl);

    if (uri != null && uri.isScheme('data')) {
      final imageBytes = _decodeBase64(quiz.imageUrl);
      imageWidget = imageBytes.isNotEmpty
          ? Image.memory(
              imageBytes, 
              width: double.infinity,
              fit: BoxFit.cover, 
            )
          : _buildErrorImage();
    } else if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
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
    } else {
      // Geçersiz, boş veya desteklenmeyen URL'ler için varsayılan widget
      imageWidget = _buildErrorImage();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageWidget,
            ),
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
}
