
import 'package:flutter/material.dart';
import 'package:myapp/login/providers/auth_provider.dart';
import 'package:myapp/profile/screens/certificate_screen.dart'; // Sertifika ekranını import et
import 'package:myapp/quiz/models/quiz_result_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Future<List<QuizResult>>? _quizResultsFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _loadResults(user.uid);
    }
  }

  void _loadResults(String userId) {
      setState(() {
        _quizResultsFuture = _firestoreService.getUserQuizResults(userId);
      });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.user;
    final DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim ve Sonuçlarım'),
      ),
      body: user == null
          ? const Center(child: Text('Lütfen profilinizi görüntülemek için giriş yapın.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                            child: user.photoURL == null ? const Icon(Icons.person, size: 40) : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.displayName ?? 'İsim Yok', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Text(user.email ?? 'Email Yok', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                Expanded(
                  child: FutureBuilder<List<QuizResult>>(
                    future: _quizResultsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Sonuçlar yüklenirken bir hata oluştu.'));
                      }
                      final results = snapshot.data;
                      if (results == null || results.isEmpty) {
                        return const Center(
                          child: Text(
                            'Henüz hiç quiz tamamlamadınız.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final percentage = (result.score / result.totalQuestions) * 100;
                          return Card(
                             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: result.quizImageUrl.isNotEmpty ? NetworkImage(result.quizImageUrl) : null,
                                child: result.quizImageUrl.isEmpty ? const Icon(Icons.quiz) : null,
                              ),
                              title: Text(result.quizTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Skor: ${result.score}/${result.totalQuestions} (${percentage.toStringAsFixed(0)}%)\n'
                                'Tarih: ${formatter.format(result.timestamp.toDate())}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              isThreeLine: true,
                              // --- DEĞİŞİKLİĞİN YAPILDIĞI YER ---
                              onTap: () {
                                // Sertifika ekranına git ve sonucu parametre olarak gönder
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CertificateScreen(result: result),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
