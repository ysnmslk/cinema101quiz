
import 'package:flutter/material.dart';
import 'package:myapp/profile/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';

import 'package:myapp/profile/screens/certificate_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      // Scaffold olmadan, sadece bir metin göster.
      return const Center(child: Text('Lütfen giriş yapın.'));
    }

    // DÜZELTME: Scaffold kaldırıldı, sadece içerik döndürülüyor.
    return Column(
      children: [
        _buildProfileHeader(user),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Tamamlanan Quizler',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: _buildResultsList(firestoreService, user.uid),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(user) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
          ),
          const SizedBox(height: 16),
          Text(user.displayName ?? 'Anonim Kullanıcı', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(user.email ?? '', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResultsList(FirestoreService firestoreService, String userId) {
    return StreamBuilder<List<QuizResultDetails>>(
      stream: firestoreService.getUserResultsWithDetailsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Henüz hiç quiz tamamlamadınız.'));
        }

        final results = snapshot.data!;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final detail = results[index];
            final quiz = detail.quiz;
            final result = detail.result;
            final double scorePercentage = result.totalQuestions > 0
                ? (result.score / result.totalQuestions) * 100
                : 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Image.network(
                  quiz.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                   errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                ),
                title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Puan: ${result.score}/${result.totalQuestions} (%${scorePercentage.toStringAsFixed(1)})'
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CertificateScreen(resultDetails: detail),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
