
import 'package:flutter/material.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/shared/bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) {
      // Kullanıcı giriş yapmamışsa, bu ekranın görünmemesi gerekir ama yine de kontrol edelim.
      return const Scaffold(
        body: Center(child: Text('Lütfen giriş yapın.')),
        bottomNavigationBar: BottomNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? 'Profil'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 12),
          Text(user.displayName ?? '', style: Theme.of(context).textTheme.headlineSmall),
          Text(user.email ?? '', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Çözülen Quizler', style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: StreamBuilder<List<UserQuizResultWithQuiz>>(
              stream: firestoreService.getUserResultsWithQuizDetails(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Sonuçlar yüklenemedi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Henüz hiç quiz çözmediniz.'));
                }

                final results = snapshot.data!;

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final result = item.result;
                    final quiz = item.quiz;

                    return ListTile(
                      leading: quiz.imageUrl.isNotEmpty
                          ? Image.network(quiz.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported, size: 50),
                      title: Text(quiz.title),
                      subtitle: Text('Puan: ${result.score} / ${result.totalQuestions}'),
                      trailing: Text(
                        // Tarihi daha okunabilir bir formata çevirelim
                        '${result.dateCompleted.toDate().day}/${result.dateCompleted.toDate().month}/${result.dateCompleted.toDate().year}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
