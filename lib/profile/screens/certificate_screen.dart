
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // HATA İÇİN EKLENDİ
import 'package:myapp/quiz/services/firestore_service.dart';

class CertificateScreen extends StatelessWidget {
  final UserQuizResultWithQuiz resultWithQuiz;

  const CertificateScreen({super.key, required this.resultWithQuiz});

  String _getExpertiseLevel(double scorePercentage) {
    if (scorePercentage >= 90) {
      return 'Profesyonel (Sinema Eleştirmeni)';
    }
    if (scorePercentage >= 70) {
      return 'Uzman İzleyici';
    }
    if (scorePercentage >= 50) {
      return 'Bilgili İzleyici';
    }
    return 'Tekrar İzlemeniz Gerekmektedir';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = resultWithQuiz.quiz;
    final result = resultWithQuiz.result;
    final scorePercentage = (result.score / result.totalQuestions) * 100;
    final expertiseLevel = _getExpertiseLevel(scorePercentage);
    final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(result.dateCompleted.toDate());

    // TODO: Kullanıcı adını AuthService'den al.
    const userName = "Kullanıcı"; // Geçici

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarı Belgesi'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24.0),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TEBRİKLER!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 40,
                  // TODO: Kullanıcı fotoğrafını AuthService'den al.
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sayın $userName,',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    children: [
                      const TextSpan(text: '\''),
                      TextSpan(
                        text: quiz.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '\' filmine ait testte '),
                      TextSpan(
                        text: '${result.score}/${result.totalQuestions}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' doğru cevap vererek '),
                      TextSpan(
                        text: expertiseLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const TextSpan(text: ' seviyesine ulaştınız.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text(
                      'Tarih: $formattedDate',
                      style: theme.textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        // TODO: Paylaşma işlevselliği eklenecek
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Paylaşma özelliği yakında eklenecek!')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
