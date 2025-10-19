
// ÖNEMLİ: Bu betiği çalıştırmadan önce Firebase projenizin yapılandırıldığından
// ve Flutter projenizin Firebase'e bağlı olduğundan emin olun.
// FlutterFire CLI ile yapılandırma yaptıysanız, lib/firebase_options.dart dosyası mevcut olmalıdır.

import "package:firebase_core/firebase_core.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/widgets.dart";
import "package:myapp/firebase_options.dart";

// --- ÖRNEK VERİLER (Tüm String'ler çift tırnak ile güncellendi) ---

final List<Map<String, dynamic>> sampleQuizzesData = [
  {
    "quiz": {
      "title": "Yüzüklerin Efendisi Bilgi Testi",
      "description": "Orta Dünya'nın kaderini ne kadar iyi biliyorsun? Frodo ve arkadaşlarının destansı yolculuğundaki detayları hatırla.",
      "category": "Fantastik Film",
      "imageUrl": "https://i.redd.it/jxiqczw9a7l61.jpg",
      "durationMinutes": 5,
      "totalQuestions": 3,
    },
    "questions": [
      {
        "question_text": "Frodo'nun Tek Yüzük'ü yok etmek için gitmesi gereken dağın adı nedir?",
        "options": ["Yalnız Dağ", "Hüküm Dağı", "Puslu Dağlar", "Demir Tepeler"],
        "correct_option_index": 1,
      },
      {
        "question_text": "Gandalf, Moria Madenleri'nde hangi kadim iblisle savaşmıştır?",
        "options": ["Smaug", "Saruman", "Balrog", "Shelob"],
        "correct_option_index": 2,
      },
      {
        "question_text": "Aragorn'un soyundan geldiği ve bir zamanlar Sauron'u yenen kral kimdir?",
        "options": ["Elendil", "Isildur", "Gil-galad", "Theoden"],
        "correct_option_index": 1,
      }
    ]
  },
  {
    "quiz": {
      "title": "Genel Kültür Karma",
      "description": "Tarihten sanata, bilimden coğrafyaya farklı alanlardaki bilgini test et. Bakalım kaç doğru yapacaksın?",
      "category": "Genel Kültür",
      "imageUrl": "https://img.freepik.com/free-vector/hand-drawn-question-mark-pattern_23-2149416654.jpg",
      "durationMinutes": 10,
      "totalQuestions": 4,
    },
    "questions": [
      {
        "question_text": "Mona Lisa tablosu hangi ünlü müzede sergilenmektedir?",
        "options": ["British Museum", "Prado Müzesi", "Louvre Müzesi", "Uffizi Galerisi"],
        "correct_option_index": 2,
      },
      {
        "question_text": "Dünyanın en yüksek dağı hangisidir?",
        "options": ["K2", "Kangchenjunga", "Lhotse", "Everest Dağı"],
        "correct_option_index": 3,
      },
      {
        "question_text": "Periyodik tabloda 'Ag' simgesiyle gösterilen element hangisidir?",
        "options": ["Altın", "Gümüş", "Argon", "Alüminyum"],
        "correct_option_index": 1,
      },
       {
        "question_text": "Türkiye'nin başkenti hangi coğrafi bölgededir?",
        "options": ["Doğu Anadolu", "Akdeniz", "İç Anadolu", "Marmara"],
        "correct_option_index": 2,
      },
    ]
  }
];

/// Bu ana fonksiyon, Firestore veritabanını örnek verilerle doldurur.
Future<void> main() async {
  // Script'in Flutter servislerini kullanabilmesi için binding'i başlatıyoruz.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i bu bağımsız script içinde başlatmamız gerekiyor.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  print("Firebase bağlantısı başarılı.");

  // Önce mevcut verileri temizleyelim (isteğe bağlı ama önerilir)
  print("Mevcut veriler temizleniyor...");
  await _db.collection("quizzes").get().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
  await _db.collection("quiz_questions").get().then((snapshot) {
    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  });
  print("Veriler temizlendi.");

  print("Yeni veriler ekleniyor...");

  // Her bir örnek quiz için işlem yap
  for (var quizData in sampleQuizzesData) {
    // 1. Quizi 'quizzes' koleksiyonuna ekle
    final quizInfo = quizData["quiz"] as Map<String, dynamic>;
    final quizDocRef = await _db.collection("quizzes").add(quizInfo);
    final newQuizId = quizDocRef.id; // Firebase tarafından oluşturulan yeni ID'yi al

    print("Eklendi: ${quizInfo['title']} (ID: $newQuizId)");

    // 2. Bu quize ait soruları 'quiz_questions' koleksiyonuna ekle
    final questions = quizData["questions"] as List<Map<String, dynamic>>;
    for (var questionData in questions) {
      // Soru verisine, hangi quize ait olduğunu belirten 'quiz_id' alanını ekle
      questionData["quiz_id"] = newQuizId;
      await _db.collection("quiz_questions").add(questionData);
    }
     print(" -> ${questions.length} adet soru eklendi.");
  }

  print("\nVeritabanı başarıyla dolduruldu!");
}

