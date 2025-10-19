
// Bu dosya, bir sınav sorusunu temsil eden Question modelini içerir.
// Firestore'daki 'quiz_questions' koleksiyonundaki her bir belge bu modele karşılık gelir.

class Question {
  final String id; // Firestore'daki belge ID'si
  final String quizId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  // Firestore'dan gelen veriyi Question nesnesine dönüştüren factory constructor.
  factory Question.fromFirestore(String documentId, Map<String, dynamic> data) {
    return Question(
      id: documentId,
      quizId: data['quiz_id'] ?? '',
      questionText: data['question_text'] ?? 'Soru metni bulunamadı',
      // Firestore'dan gelen List<dynamic> türünü List<String>'e çeviriyoruz.
      options: List<String>.from(data['options'] ?? []),
      correctOptionIndex: data['correct_option_index'] ?? 0,
    );
  }
}
