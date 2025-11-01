
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/screens/quiz_intro_screen.dart'; // DOĞRU DOSYA İÇE AKTARILDI
import 'package:transparent_image/transparent_image.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final bool isCompleted;
  final bool isNew;
  final bool showImage; 

  const QuizCard({ 
    super.key,
    required this.quiz,
    this.isCompleted = false,
    this.isNew = false,
    this.showImage = true, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              // YÖNLENDİRME DOĞRU WIDGET'A YAPILDI
              builder: (context) => QuizIntroScreen(quiz: quiz),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            if (showImage)
              _buildQuizImage(),
            _buildGradientOverlay(context),
            _buildTitleAndInfo(),
            if (isCompleted || isNew)
              _buildStatusBadge(context, isCompleted: isCompleted, isNew: isNew),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizImage() {
    return Hero(
      tag: quiz.id, 
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage, 
        image: quiz.imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        imageErrorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    final gradientColors = showImage 
      ? [Colors.black.withOpacity(0.8), Colors.transparent]
      : [Colors.black.withOpacity(0.9), Colors.black.withOpacity(0.7)];

    return Container(
      height: showImage ? 200 : null, 
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildTitleAndInfo() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            quiz.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
           Text(
            '${quiz.questions.length} Soru • ${quiz.durationMinutes} Dakika',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, {required bool isCompleted, required bool isNew}) {
    final badgeColor = isCompleted ? Colors.green.withOpacity(0.8) : Colors.blue.withOpacity(0.9);
    final badgeText = isCompleted ? 'ÇÖZÜLDÜ' : 'YENİ';
    final badgeIcon = isCompleted ? Icons.check_circle : Icons.new_releases;

    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(badgeIcon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              badgeText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
