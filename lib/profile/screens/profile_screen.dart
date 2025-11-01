import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/profile/screens/certificate_screen.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/shared/bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// 🔹 Kullanıcının 100 üzerinden puanını hesaplar.
  num _calculateScoreOutOf100(int score, int totalQuestions) {
    if (totalQuestions == 0) return 0;

    switch (totalQuestions) {
      case 1:
        return score * 100.0;
      case 2:
        return score * 50.0;
      case 5:
        return score * 20.0;
      case 10:
        return score * 10.0;
      case 20:
        return score * 5.0;
      case 25:
        return score * 4.0;
      case 40:
        return score * 2.5;
      case 50:
        return score * 2.0;
      case 100:
        return score * 1.0;
      default:
        // Varsayılan olarak oransal hesaplama
        return score;
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(
          child: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? 'Profil'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: StreamBuilder<List<UserQuizResultWithQuiz>>(
        stream: _firestoreService.getUserResultsWithQuizDetails(user.uid),
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

          final results = snapshot.data!;
          final totalTests = results.length;

          // 🔹 Ortalama puan hesaplama (100 üzerinden)
          final totalScoreSum = results.fold<double>(
            0.0,
            (sum, item) =>
                sum + _calculateScoreOutOf100(item.result.score, item.result.totalQuestions),
          );
          double averageScore = totalTests > 0 ? totalScoreSum / totalTests : 0;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatsCard(theme, totalTests, averageScore),
              const SizedBox(height: 24),
              Text(
                'Çözülen Testler',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...results.map((resultWithQuiz) => _buildResultTile(context, resultWithQuiz)),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildStatsCard(ThemeData theme, int totalTests, double averageScore) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              theme,
              Icons.check_circle_outline,
              'Test Çözüldü',
              totalTests.toString(),
            ),
            _buildStatItem(
              theme,
              Icons.leaderboard_outlined,
              'Ortalama Puan',
              '${averageScore.round()}/100',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildResultTile(BuildContext context, UserQuizResultWithQuiz resultWithQuiz) {
    final result = resultWithQuiz.result;
    final quiz = resultWithQuiz.quiz;
    final formattedDate = DateFormat('dd MMMM yyyy', 'tr_TR').format(result.dateCompleted.toDate());

    final scoreOutOf100 = _calculateScoreOutOf100(result.score, result.totalQuestions);

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Puan: ${scoreOutOf100.round()}/100\nTarih: $formattedDate'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CertificateScreen(resultWithQuiz: resultWithQuiz),
            ),
          );
        },
      ),
    );
  }
}
