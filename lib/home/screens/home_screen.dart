
import 'package:flutter/material.dart';
import 'package:myapp/add_quiz/screens/add_quiz_screen.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/home/widgets/quiz_card.dart';
import 'package:myapp/shared/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizler'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<Set<String>>(
        // 1. Kullanıcının tamamladığı quizlerin ID'lerini dinle
        stream: user != null ? _firestoreService.getCompletedQuizzes(user.uid) : Stream.value({}),
        builder: (context, completedQuizzesSnapshot) {
          final completedQuizzes = completedQuizzesSnapshot.data ?? {};

          return StreamBuilder<List<Quiz>>(
            // 2. Tüm quizleri (en yeniden eskiye sıralı) dinle
            stream: _firestoreService.getQuizzes(),
            builder: (context, quizSnapshot) {
              if (quizSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (quizSnapshot.hasError) {
                return Center(child: Text('Bir hata oluştu: ${quizSnapshot.error}'));
              }
              if (!quizSnapshot.hasData || quizSnapshot.data!.isEmpty) {
                return const Center(child: Text('Gösterilecek quiz bulunamadı.'));
              }

              final quizzes = quizSnapshot.data!;

              // 3. Quiz listesini oluştur ve her bir karta gerekli bilgiyi gönder
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Ekran genişliğine göre ayarlanabilir
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.85, // Kartların en-boy oranı
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  final isCompleted = completedQuizzes.contains(quiz.id);
                  
                  // Quiz'in son 10 gün içinde eklenip eklenmediğini kontrol et
                  final isNew = DateTime.now().difference(quiz.createdAt.toDate()).inDays <= 10;

                  return QuizCard(
                    quiz: quiz,
                    isCompleted: isCompleted, // Tamamlanma durumu
                    isNew: isNew, // Yenilik durumu
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddQuizScreen()),
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
