
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Firestore örneğini alın
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> addQuizQuestionsBatch() async {
  // Yeni bir WriteBatch başlatın
  final WriteBatch batch = _firestore.batch();

  // Sorularınızı bir liste (List<Map<String, dynamic>>) olarak tanımlayın
  final List<Map<String, dynamic>> quizQuestions = [
    {
      "text": "Fransa'nın başkenti neresidir?",
      "options": ["Londra", "Paris", "Berlin", "Roma"],
      "correctAnswerIndex": 1, // Paris
      "category": "Coğrafya"
    },
    {
      "text": "Güneş Sistemi'ndeki en büyük gezegen hangisidir?",
      "options": ["Mars", "Dünya", "Jüpiter", "Satürn"],
      "correctAnswerIndex": 2, // Jüpiter
      "category": "Astronomi"
    },
    // Diğer 18 sorunuzu buraya ekleyin...
    {
      "text": "Son soru metni?",
      "options": ["A", "B", "C", "D"],
      "correctAnswerIndex": 0,
      "category": "Genel Kültür"
    }
  ];

  try {
    // Her bir soru için batch'e bir 'set' işlemi ekleyin
    for (var question in quizQuestions) {
      // 'questions' koleksiyonuna yeni bir belge referansı oluşturun
      // doc() fonksiyonu ile otomatik ID alabilirsiniz
      final DocumentReference questionRef = _firestore.collection("questions").doc();
      batch.set(questionRef, question);
    }

    // Tüm batch işlemlerini tek seferde commit edin (gönderin)
    await batch.commit();
    print("Tüm quiz soruları başarıyla eklendi!");
  } catch (e) {
    print("Quiz sorularını eklerken bir hata oluştu: $e");
  }
}

// Bu fonksiyonu uygulamanızda uygun bir yerden çağırabilirsiniz, örneğin bir buton tıklamasında:
/*
ElevatedButton(
  onPressed: () {
    addQuizQuestionsBatch();
  },
  child: Text("20 Soru Ekle"),
)
*/
