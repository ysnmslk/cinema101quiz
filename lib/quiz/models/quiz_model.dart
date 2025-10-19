
// Bu dosya, bir sınavın temel bilgilerini temsil eden Quiz modelini içerir.
// Firestore'daki 'quizzes' koleksiyonundaki her bir belge bu modele karşılık gelir.

import 'package:cloud_firestore/cloud_firestore.dart';


class Quiz {
  final String id; // Firestore'daki belge ID'si
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int durationMinutes;
  final int totalQuestions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.durationMinutes,
    required this.totalQuestions,
  });

  // Firestore'dan gelen veriyi (Map<String, dynamic>) Quiz nesnesine dönüştüren factory constructor.
  factory Quiz.fromFirestore(String documentId, Map<String, dynamic> data) {
    return Quiz(
      id: documentId,
      title: data['title'] ?? 'Başlık Yok',
      description: data['description'] ?? 'Açıklama Yok',
      category: data['category'] ?? 'Kategori Yok',
      imageUrl: data['imageUrl'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
    );
  }
}
