
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/services/auth_service.dart';
import '../home/widgets/quiz_card.dart';
import '../profile/services/firestore_service.dart';
import '../quiz/models/quiz_model.dart';
import '../quiz/services/quiz_service.dart';
import '../shared/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAdmin = false;
  bool _isLoadingAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final isAdmin = await firestoreService.isAdmin(userId);
      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _isLoadingAdmin = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _isLoadingAdmin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Quiz> _filterQuizzes(List<Quiz> quizzes, String query) {
    if (query.isEmpty) {
      return quizzes;
    }
    
    final lowerQuery = query.toLowerCase();
    return quizzes.where((quiz) {
      return quiz.title.toLowerCase().contains(lowerQuery) ||
          quiz.description.toLowerCase().contains(lowerQuery) ||
          quiz.topic.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final quizService = Provider.of<QuizService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cin101'),
        leading: kIsWeb
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          // Sadece admin kullanıcılar için quiz ekleme butonu
          if (_isAdmin && !_isLoadingAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Quiz Ekle',
              onPressed: () {
                context.go('/add-quiz');
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await authService.signOut();
              // ignore: use_build_context_synchronously
              context.go('/login');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Quiz ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Quiz>>(
        stream: quizService.getQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Henüz quiz bulunmuyor.'));
          }
          
          // Debug: Quiz resim URL'lerini kontrol et
          if (kDebugMode) {
            for (var quiz in snapshot.data!) {
              debugPrint('Quiz: ${quiz.title}, ImageURL: ${quiz.imageUrl}');
            }
          }
          
          // Arama sorgusuna göre quizleri filtrele
          final filteredQuizzes = _filterQuizzes(snapshot.data!, _searchQuery);
          
          if (filteredQuizzes.isEmpty && _searchQuery.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aradığınız kriterlere uygun quiz bulunamadı',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }
          
          // Responsive grid için ekran genişliğine göre sütun sayısı belirle
          final screenWidth = MediaQuery.of(context).size.width;
          int crossAxisCount;
          
          if (screenWidth < 600) {
            // Cep telefonu: 2 sütun
            crossAxisCount = 2;
          } else if (screenWidth < 1200) {
            // Tablet: 4 sütun
            crossAxisCount = 4;
          } else {
            // Bilgisayar: Ekran genişliğine göre otomatik (her 300px için 1 sütun, min 4, max 8)
            crossAxisCount = (screenWidth / 300).floor().clamp(4, 8);
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.7, // Kart genişliği/yüksekliği oranı (daha yüksek kartlar için)
            ),
            itemCount: filteredQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = filteredQuizzes[index];
              return QuizCard(quiz: quiz);
            },
          );
        },
      ),
      drawer: kIsWeb ? const AppDrawer(currentIndex: 0) : null,
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
              currentIndex: 0,
              onTap: (index) {
                switch (index) {
                  case 0:
                    // Zaten ana sayfadayız
                    break;
                  case 1:
                    context.go('/profile');
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
}
