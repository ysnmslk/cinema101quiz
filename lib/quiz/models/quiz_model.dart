


// --- Option (Seçenek) Modeli ---
class Option {
  String text;
  bool isCorrect;

  Option({required this.text, this.isCorrect = false});

  // Firestore'a yazmak için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  // Firestore'dan okumak için Map'ten nesne oluşturur
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

  Question({
    this.id = '', // ID başlangıçta boş olabilir
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });

  // Firestore'a yazmak için Map'e dönüştürür
  Map<String, dynamic> toMap() {
    // Doğru cevap indeksine göre seçeneklerin isCorrect alanını ayarla
    for (int i = 0; i < options.length; i++) {
      options[i].isCorrect = (i == correctAnswerIndex);
    }
    return {
      // 'id' alanını Map'e dahil ETMİYORUZ, çünkü bu sub-collection'da anlamsızdır.
      'text': text,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }

  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    var optionsList = (map['options'] as List<dynamic>? ?? [])
        .map((optionMap) => Option.fromMap(optionMap))
        .toList();

    int correctIndex = optionsList.indexWhere((opt) => opt.isCorrect);
    
    return Question(
      id: documentId,
      text: map['text'] ?? '',
      options: optionsList,
      // Eğer hiçbir seçenek 'isCorrect' olarak işaretlenmemişse, -1 döner. 
      // Bu durumu ele almak önemlidir. Genellikle bir doğrulama hatasıdır.
      correctAnswerIndex: correctIndex, 
    );
  }
}

// --- Quiz Modeli ---
class Quiz {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int durationMinutes;
  final int totalQuestions;
  List<Question> questions;

  Quiz({
    this.id = '', // ID başlangıçta boş olabilir
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.durationMinutes = 0, // Varsayılan değerler ekleyelim
    this.totalQuestions = 0,
    this.questions = const [],
  });

  // Firestore'a yazmak için Map'e dönüştürür
  // --- GÜNCELLENMİŞ KISIM --- //
  Map<String, dynamic> toMap() {
    return {
      // 'id' yi ve 'questions' listesini BURADA DAHİL ETMİYORUZ.
      // 'id' belge adıdır, 'questions' ise bir alt koleksiyondur.
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'durationMinutes': durationMinutes, // Artık bu alanları da ekliyoruz
      'totalQuestions': questions.length, // Soru sayısını dinamik olarak hesapla
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map, String documentId) {
    return Quiz(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      // 'questions' burada yüklenmez, getQuizById gibi özel bir metotla yüklenir.
    );
  }
}
