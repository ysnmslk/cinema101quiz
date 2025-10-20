
import 'package:myapp/quiz/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.questions = const [], // Varsayılan olarak boş liste
  });

  // fromMap artık yalnızca temel alanları doldurur, soruları değil
  factory Quiz.fromMap(Map<String, dynamic> map, String documentId) {
    return Quiz(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // questions alanı burada doldurulmaz
    );
  }
}
