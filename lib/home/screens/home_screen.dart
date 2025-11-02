
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/firestore_service.dart';
import 'package:myapp/home/widgets/quiz_card.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;

    final completedQuizzesStream = user?.uid != null
        ? firestoreService.getCompletedQuizzesStream(user!.uid)
        : Stream.value(<String>{});

    // DÜZELTME: Scaffold ve AppBar kaldırıldı. Sadece içerik döndürülüyor.
    return StreamBuilder<List<Quiz>>(
      stream: firestoreService.getQuizzesStream(),
      builder: (context, quizSnapshot) {
        if (quizSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (quizSnapshot.hasError) {
          return Center(child: Text('Hata: ${quizSnapshot.error}'));
        }
        if (!quizSnapshot.hasData || quizSnapshot.data!.isEmpty) {
          return const Center(child: Text('Hiç quiz bulunamadı.'));
        }

        final quizzes = quizSnapshot.data!;

        return StreamBuilder<Set<String>>(
          stream: completedQuizzesStream,
          builder: (context, completedSnapshot) {
            final completedQuizIds = completedSnapshot.data ?? <String>{};

            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400.0,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                final isCompleted = completedQuizIds.contains(quiz.id);
                return QuizCard(
                  quiz: quiz,
                  isCompleted: isCompleted,
                );
              },
            );
          },
        );
      },
    );
  }
}
