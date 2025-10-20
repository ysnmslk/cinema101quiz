
class Question {
  final String id;
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

  factory Question.fromMap(Map<String, dynamic> map, String id) {
    return Question(
      id: id,
      quizId: map['quizId'] ?? '',
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }
}
