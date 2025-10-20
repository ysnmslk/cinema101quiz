
class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? quizId; // Zorunlu olmaktan çıkarıldı

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.quizId, // Artık opsiyonel
  });

  // Firestore'dan gelen veriyi modele dönüştürmek için fabrika kurucusu
  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    return Question(
      id: documentId,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      quizId: map['quizId'],
    );
  }
}
