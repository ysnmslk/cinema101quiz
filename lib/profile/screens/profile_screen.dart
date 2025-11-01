
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/home/widgets/quiz_card.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart'; // Eklendi

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Lütfen giriş yapın.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Çıkış Yap',
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(user.displayName ?? 'İsim Yok', style: Theme.of(context).textTheme.headlineSmall),
                Text(user.email ?? 'E-posta Yok', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const Divider(height: 40),
          Text('Çözülen Testler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          // FutureBuilder'ı doğru fonksiyon ve tiple güncelledik
          FutureBuilder<List<UserQuizResult>>(
            future: firestoreService.getCompletedQuizResults(user.uid), // DOĞRU FONKSİYON KULLANILDI
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Henüz hiç test çözmediniz.'));
              }

              final completedQuizzes = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: completedQuizzes.length,
                itemBuilder: (context, index) {
                  final result = completedQuizzes[index];
                  
                  // Quiz detaylarını ayrıca çekmek için FutureBuilder
                  return FutureBuilder<Quiz?>(
                    future: firestoreService.getQuizById(result.quizId),
                    builder: (context, quizSnapshot) {
                      if (quizSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Yükleniyor...'));
                      }
                      if (!quizSnapshot.hasData || quizSnapshot.data == null) {
                        // Quiz silinmiş veya bulunamıyor olabilir.
                        return const SizedBox.shrink(); 
                      }
                      final quiz = quizSnapshot.data!;

                      // QuizCard'ı kullanarak sonucu göster
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: QuizCard(
                          quiz: quiz,
                          isCompleted: true,
                          showImage: false, // Profilde resimleri gösterme
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
