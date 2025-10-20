
import 'package:myapp/quiz/models/question_model.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Question> questions; // Sorular listesini ekliyoruz

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.questions = const [], // Varsayılan olarak boş liste atıyoruz
  });

  factory Quiz.fromMap(Map<String, dynamic> map, String id) {
    return Quiz(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
