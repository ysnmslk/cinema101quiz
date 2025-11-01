
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Quiz Yönetimi ---

  // Tüm quizleri getir (oluşturulma tarihine göre en yeniden eskiye sıralı)
  Stream<List<Quiz>> getQuizzes() {
    return _db
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList());
  }

  // Belirli bir ID'ye sahip quiz'i getir
  Future<Quiz> getQuizById(String quizId) {
    return _db.collection('quizzes').doc(quizId).get().then((doc) => Quiz.fromFirestore(doc));
  }

  // Yeni bir quiz ekle
  Future<void> addQuiz(Quiz quiz) {
    return _db.collection('quizzes').add(quiz.toMap());
  }

  // --- Kullanıcı Sonuçları Yönetimi ---

  // Kullanıcının tamamladığı quizlerin ID'lerini getir
  Stream<Set<String>> getCompletedQuizzes(String userId) {
    if (userId.isEmpty) {
      return Stream.value({});
    }
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data()!.containsKey('completedQuizzes')) {
        final List<dynamic> completed = snapshot.data()!['completedQuizzes'] ?? [];
        return Set<String>.from(completed);
      } else {
        return {};
      }
    });
  }

  // Quiz'i tamamlandı olarak işaretle (genel tamamlama listesi için)
  Future<void> markQuizAsCompleted(String userId, String quizId) {
    if (userId.isEmpty || quizId.isEmpty) return Future.value();
    return _db.collection('users').doc(userId).set({
      'completedQuizzes': FieldValue.arrayUnion([quizId])
    }, SetOptions(merge: true));
  }

  // Detaylı quiz sonucunu kaydet
  Future<void> saveQuizResult(String userId, UserQuizResult result) {
     if (userId.isEmpty) return Future.value();
    return _db
        .collection('users')
        .doc(userId)
        .collection('results')
        .doc(result.quizId)
        .set(result.toMap());
  }

  // Kullanıcının tüm sonuçlarını quiz detayları ile birlikte getir
  Stream<List<UserQuizResultWithQuiz>> getUserResultsWithQuizDetails(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    // Bu fonksiyon, karmaşık yapısı nedeniyle birden fazla veritabanı okuması gerektirir.
    // Önce kullanıcının tüm sonuçlarını alıp, sonra her bir sonuç için quiz detayını çekeceğiz.
    // Gerçek bir uygulamada bu, performansı optimize etmek için bir backend fonksiyonu (Cloud Function)
    // ile yapılabilir, ancak istemci tarafında bu şekilde uygulayabiliriz.

    final resultsStream = _db.collection('users').doc(userId).collection('results').snapshots();

    return resultsStream.asyncMap((resultsSnapshot) async {
      final List<UserQuizResultWithQuiz> detailedResults = [];
      for (var doc in resultsSnapshot.docs) {
        final result = UserQuizResult.fromFirestore(doc);
        try {
          final quiz = await getQuizById(result.quizId);
          detailedResults.add(UserQuizResultWithQuiz(result: result, quiz: quiz));
        } catch (e) {
          // Quiz silinmiş veya ulaşılamıyor olabilir, bu sonucu atla
        }
      }
      // Sonuçları tarihe göre sırala
      detailedResults.sort((a, b) => b.result.dateCompleted.compareTo(a.result.dateCompleted));
      return detailedResults;
    });
  }
}
