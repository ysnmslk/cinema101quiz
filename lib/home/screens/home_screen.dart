
import 'package:flutter/material.dart';
import 'package:myapp/home/widgets/home_drawer.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart'; // Firestore servisimizi import ediyoruz
import 'package:myapp/quiz/widgets/quiz_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Firestore servisimizi başlatıyoruz
  final FirestoreService _firestoreService = FirestoreService();
  // Quiz verilerini tutacağımız Future'ı tanımlıyoruz
  late Future<List<Quiz>> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    // Ekran ilk açıldığında quizleri getirme işlemini başlatıyoruz
    _quizzesFuture = _firestoreService.getQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Uygulaması'),
        centerTitle: true,
      ),
      drawer: const HomeDrawer(),
      // FutureBuilder ile verilerin yüklenme durumunu yönetiyoruz
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          // Veriler yükleniyorsa... 
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Hata oluştuysa...
          else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          // Veri yoksa veya boşsa...
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Gösterilecek quiz bulunamadı.'));
          }
          // Veriler başarıyla geldiyse...
          else {
            final quizzes = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Yan yana 2 kart
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.8, // Kartların en-boy oranı
                ),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  return QuizCard(quiz: quizzes[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }
}

