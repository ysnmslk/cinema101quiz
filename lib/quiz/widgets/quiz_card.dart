
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/screens/quiz_screen.dart';

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
    // --- Dinamik Yazı Tipi Boyutu İçin --- //
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Ekran genişliğine göre temel bir oran belirleyelim
    // Bu oranları projenizin tasarımına göre daha da hassaslaştırabilirsiniz
    double titleFontSize = screenWidth * 0.045; // Genişliğin %4.5'i
    double descriptionFontSize = screenWidth * 0.035; // Genişliğin %3.5'i

    // Çok büyük veya çok küçük olmasını engellemek için sınırlar koyalım
    titleFontSize = titleFontSize.clamp(14.0, 20.0); // Min 14, Max 20
    descriptionFontSize = descriptionFontSize.clamp(12.0, 16.0); // Min 12, Max 16
    // ------------------------------------ //

    Widget imageWidget;
    if (quiz.imageUrl.startsWith('data:image')) {
      final imageBytes = _decodeBase64(quiz.imageUrl);
      imageWidget = imageBytes.isNotEmpty
          ? Image.memory(imageBytes, fit: BoxFit.cover)
          : _buildErrorImage();
    } else {
      imageWidget = Image.network(
        quiz.imageUrl,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: imageWidget,
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      quiz.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize, // Dinamik boyut
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      quiz.description,
                      style: TextStyle(
                        fontSize: descriptionFontSize, // Dinamik boyut
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}
