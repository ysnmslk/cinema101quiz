
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/services/auth_service.dart';
import '../profile/models/solved_quiz.dart';
import '../profile/services/firestore_service.dart';
import '../profile/screens/certificate_screen.dart';
import '../quiz/models/quiz_models.dart';
import '../quiz/services/quiz_service.dart';
import '../shared/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lütfen giriş yapın.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        elevation: 0,
        leading: kIsWeb
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user.displayName, user.email),
            const SizedBox(height: 32),
            _buildStatsSection(context, firestoreService, user.uid),
            const SizedBox(height: 32),
            _buildSolvedQuizzesSection(context, firestoreService, user.uid),
          ],
        ),
      ),
      drawer: kIsWeb ? const AppDrawer(currentIndex: 1) : null,
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
              currentIndex: 1,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    // Zaten profil sayfasındayız
                    break;
                  case 2:
                    context.go('/settings');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Ayarlar',
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String? displayName, String? email) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName ?? 'İsimsiz',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              email ?? 'E-posta yok',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, FirestoreService firestoreService, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'İstatistikler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: firestoreService.getUserStats(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('İstatistikler yüklenemedi.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Henüz istatistik yok.'));
            }

            final stats = snapshot.data!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Toplam Puan', stats['totalScore'].toString()),
                _buildStatItem(context, 'Çözülen Quiz', stats['quizzesSolved'].toString()),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildSolvedQuizzesSection(BuildContext context, FirestoreService firestoreService, String userId) {
    final quizService = Provider.of<QuizService>(context, listen: false);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son Çözülen Quizler',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<SolvedQuiz>>(
          stream: firestoreService.getSolvedQuizzes(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Quizler yüklenemedi.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Henüz quiz çözülmemiş.'));
            }

            final quizzes = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final solvedQuiz = quizzes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      solvedQuiz.quizTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Seviye: ${solvedQuiz.level}'),
                        const SizedBox(height: 4),
                        Text(
                          'Tarih: ${DateFormat.yMd().add_jm().format(solvedQuiz.dateCompleted)}',
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${solvedQuiz.score}/${solvedQuiz.totalQuestions}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    onTap: () async {
                      // Quiz bilgilerini çek ve sertifika sayfasına git
                      try {
                        debugPrint('Quiz ID: ${solvedQuiz.quizId}');
                        
                        // Loading göster
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final quiz = await quizService.getQuizById(solvedQuiz.quizId);
                        debugPrint('Quiz found: ${quiz != null}');
                        
                        // Loading'i kapat
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        
                        if (quiz == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Quiz bulunamadı.')),
                            );
                          }
                          return;
                        }
                        
                        if (context.mounted) {
                          // Quiz modelini quiz_models.dart'taki Quiz'e dönüştür
                          final quizModels = Quiz(
                            id: quiz.id,
                            title: quiz.title,
                            description: quiz.description,
                            topic: quiz.topic,
                            durationMinutes: quiz.durationMinutes,
                            imageUrl: quiz.imageUrl,
                            questions: [],
                            createdAt: quiz.createdAt ?? Timestamp.now(),
                          );
                          
                          final userResult = UserQuizResult(
                            quizId: solvedQuiz.quizId,
                            score: solvedQuiz.score,
                            totalQuestions: solvedQuiz.totalQuestions,
                            completedAt: Timestamp.fromDate(solvedQuiz.dateCompleted),
                          );
                          
                          final resultDetails = QuizResultDetails(
                            result: userResult,
                            quiz: quizModels,
                          );
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CertificateScreen(resultDetails: resultDetails),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        // Loading'i kapat
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sertifika yüklenirken hata oluştu: $e'),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                        debugPrint('Certificate error: $e');
                        debugPrint('Stack trace: $stackTrace');
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
