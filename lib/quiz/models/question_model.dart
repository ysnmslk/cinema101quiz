
// --- Option (Seçenek) Modeli ---
class Option {
  String text;
  bool isCorrect;

  Option({required this.text, this.isCorrect = false});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
    );
  }
}

// --- Question (Soru) Modeli ---
class Question {
  final String id;
  String text;
  List<Option> options;
  int correctAnswerIndex;

  // --- YAPICI (CONSTRUCTOR) TEMİZLENDİ ---
  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    // Doğru cevap indeksine göre seçeneklerin isCorrect alanını ayarla
    for (int i = 0; i < options.length; i++) {
      options[i].isCorrect = (i == correctAnswerIndex);
    }
    return {
      'id': id,
      'text': text, 
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }

  // --- fromMap METODU DÜZELTİLDİ ---
  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    var optionsList = (map['options'] as List<dynamic>? ?? [])
        .map((optionMap) => Option.fromMap(optionMap))
        .toList();

    // Firestore'daki `isCorrect: true` olan seçeneği bularak doğru indeksi belirle
    int correctIndex = optionsList.indexWhere((opt) => opt.isCorrect);
    
    // Eğer hiçbir seçenek doğru olarak işaretlenmemişse, güvenli bir varsayılan ata (0)
    if (correctIndex == -1) {
      correctIndex = 0;
    }

    // Yapıcıyı sadece doğru ve gerekli parametrelerle çağır
    return Question(
      id: documentId,
      text: map['text'] ?? '',
      options: optionsList,
      correctAnswerIndex: correctIndex, 
    );
  }
}
