
class Option {
  final String text;
  final bool isCorrect;

  Option({required this.text, required this.isCorrect});

  // Factory constructor to create an Option from a map (e.g., from Firestore)
  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      text: map['text'] as String,
      isCorrect: map['isCorrect'] as bool,
    );
  }

  // Method to convert an Option to a map (e.g., for writing to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}
