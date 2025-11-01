
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Quiz Yönetimi ---

  Stream<List<Quiz>> getQuizzes() {
    return _db
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList());
  }

  Future<Quiz?> getQuizById(String quizId) async {
    try {
      final doc = await _db.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return Quiz.fromFirestore(doc);
      }
    } catch (e) {
      // Hata durumunda veya quiz bulunamazsa null dönebilir
    }
    return null;
  }

  Future<void> addQuiz(Quiz quiz) {
    return _db.collection('quizzes').add(quiz.toMap());
  }

  // --- Kullanıcı Sonuçları Yönetimi ---

  // YENİ FONKSİYON: Kullanıcının tüm detaylı quiz sonuçlarını getir (Future olarak)
  Future<List<UserQuizResult>> getCompletedQuizResults(String userId) {
    if (userId.isEmpty) {
      return Future.value([]);
    }
    return _db
        .collection('users')
        .doc(userId)
        .collection('results')
        .orderBy('dateCompleted', descending: true) // En yeniden eskiye sırala
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => UserQuizResult.fromFirestore(doc))
            .toList());
  }


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


  Future<void> markQuizAsCompleted(String userId, String quizId) {
    if (userId.isEmpty || quizId.isEmpty) return Future.value();
    return _db.collection('users').doc(userId).set({
      'completedQuizzes': FieldValue.arrayUnion([quizId])
    }, SetOptions(merge: true));
  }


  Future<void> saveQuizResult(String userId, UserQuizResult result) {
     if (userId.isEmpty) return Future.value();
    return _db
        .collection('users')
        .doc(userId)
        .collection('results')
        .doc(result.quizId)
        .set(result.toMap());
  }


  Stream<List<UserQuizResultWithQuiz>> getUserResultsWithQuizDetails(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    final resultsStream = _db.collection('users').doc(userId).collection('results').snapshots();

    return resultsStream.asyncMap((resultsSnapshot) async {
      final List<UserQuizResultWithQuiz> detailedResults = [];
      for (var doc in resultsSnapshot.docs) {
        final result = UserQuizResult.fromFirestore(doc);
        try {
          final quiz = await getQuizById(result.quizId);
          if(quiz != null) {
            detailedResults.add(UserQuizResultWithQuiz(result: result, quiz: quiz));
          }
        } catch (e) {
          
        }
      }
      detailedResults.sort((a, b) => b.result.dateCompleted.compareTo(a.result.dateCompleted));
      return detailedResults;
    });
  }
}

// Detaylı sonuçları ve quiz bilgilerini birleştiren yardımcı bir sınıf
class UserQuizResultWithQuiz {
  final UserQuizResult result;
  final Quiz quiz;

  UserQuizResultWithQuiz({required this.result, required this.quiz});
}
