
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/login/providers/auth_provider.dart';
import 'package:myapp/quiz/data/dummy_quizzes.dart';
import 'package:myapp/quiz/widgets/quiz_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appAuthProvider = Provider.of<AppAuthProvider>(context);
    final user = appAuthProvider.user;
    
    // Sadece yayınlanmış quizleri filtrele
    final publishedQuizzes = dummyQuizzes.where((quiz) => quiz.isPublished).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Quizler'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AppAuthProvider>().signOut();
              },
              tooltip: 'Çıkış Yap',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Yan yana iki kart göster
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75, // Kartların en-boy oranı
          ),
          itemCount: publishedQuizzes.length,
          itemBuilder: (context, index) {
            final quiz = publishedQuizzes[index];
            return QuizCard(quiz: quiz);
          },
        ),
      ),
    );
  }
}
