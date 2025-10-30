
import 'package:flutter/material.dart';
import 'package:myapp/add_quiz/screens/add_quiz_screen.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/shared/bottom_nav.dart';
import 'package:myapp/quiz/models/quiz_model.dart'; // Güncellendi
import 'package:myapp/home/widgets/quiz_card.dart';   // Güncellendi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Quiz>> _quizzesFuture;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzesFuture = _firestoreService.getQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        automaticallyImplyLeading: false, // Geri tuşunu kaldır
        actions: const [
          // Arama butonu gibi eylemler buraya eklenebilir
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Quiz Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Quiz>>(
              future: _quizzesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Gösterilecek quiz bulunamadı.'));
                }

                final quizzes = snapshot.data!
                    .where((quiz) =>
                        quiz.title.toLowerCase().contains(_searchTerm) ||
                        quiz.description.toLowerCase().contains(_searchTerm))
                    .toList();

                if (quizzes.isEmpty) {
                  return const Center(child: Text('Arama kriterlerine uygun quiz bulunamadı.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // İki sütunlu grid
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8, // Kartların en-boy oranı
                  ),
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    return QuizCard(quiz: quizzes[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddQuizScreen()),
          ).then((_) {
            // AddQuizScreen'den geri dönüldüğünde listeyi yenile
            setState(() {
              _loadQuizzes();
            });
          });
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Ana sayfa index'i
    );
  }
}
