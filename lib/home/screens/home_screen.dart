
import 'package:flutter/material.dart';
import 'package:myapp/admin/screens/add_quiz_screen.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:myapp/quiz/widgets/quiz_card.dart';
import 'package:myapp/shared/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Quiz> _quizzes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      var quizzes = await _firestoreService.getQuizzes();
      if (mounted) {
        setState(() {
          _quizzes = quizzes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quizler yüklenirken bir hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Quiz> get _filteredQuizzes {
    if (_searchQuery.isEmpty) {
      return _quizzes;
    }
    return _quizzes
        .where((quiz) =>
            quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            quiz.category.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _navigateToAddQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddQuizScreen(),
      ),
    );
    if (result == true) {
      _loadQuizzes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddQuiz,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuizzes,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Quiz veya kategori ara...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredQuizzes.isEmpty
                      ? const Center(
                          child: Text('Aradığınız kriterlere uygun quiz bulunamadı.'),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = (constraints.maxWidth / 180).floor();
                            // --- DEĞİŞİKLİĞİN YAPILDIĞI YER ---
                            return GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                // childAspectRatio kaldırıldı, yerine mainAxisExtent kullanıldı.
                                mainAxisExtent: 250, // Her bir kart için sabit yükseklik
                              ),
                              itemCount: _filteredQuizzes.length,
                              itemBuilder: (context, index) {
                                final quiz = _filteredQuizzes[index];
                                return QuizCard(quiz: quiz);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
