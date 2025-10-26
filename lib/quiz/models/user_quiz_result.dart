import 'package:myapp/quiz/models/quiz_model.dart';

// Bu model sınıfı, bir kullanıcının bir quiz'den aldığı sonucu
// ilgili quiz'in detaylarıyla birleştirir.
class UserQuizResult {
  final Quiz quiz; // Quiz başlığı, açıklaması vb. için
  final QuizResult result; // Kullanıcı skoru, tarihi vb. için

  UserQuizResult({required this.quiz, required this.result});
}