
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/user_quiz_result.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/shared/bottom_nav.dart'; // Alt navigasyon importu

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late Future<List<UserQuizResult>> _userResultsFuture;

  @override
  void initState() {
    super.initState();
    // Kullanıcı giriş yapmışsa sonuçları yükle
    if (_currentUser != null) {
      _userResultsFuture = _firestoreService.getUserResultsWithQuizDetails(_currentUser!.uid);
    } else {
      // Kullanıcı giriş yapmamışsa, boş bir Future ata
      _userResultsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        automaticallyImplyLeading: false, // Geri tuşunu gizle
      ),
      body: _currentUser == null
          ? const Center(
              child: Text('Sonuçları görmek için lütfen giriş yapın.'),
            )
          : FutureBuilder<List<UserQuizResult>>(
              future: _userResultsFuture,
              builder: (context, snapshot) {
                // Yükleniyor durumu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Hata durumu
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Sonuçlar yüklenirken bir hata oluştu: ${snapshot.error}'),
                  );
                }
                // Veri yok veya boş liste durumu
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Henüz hiç quiz çözmediniz.'),
                  );
                }

                final results = snapshot.data!;

                // Başarılı veri durumu
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        title: Text(
                          item.quiz.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          item.quiz.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          'Skor: ${item.result.score}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple, // Skoru vurgula
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
       bottomNavigationBar: const BottomNavBar(currentIndex: 1), // Profil ekranı index'i
    );
  }
}
