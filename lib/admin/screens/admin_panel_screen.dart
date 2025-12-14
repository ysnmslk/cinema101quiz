import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/services/auth_service.dart';
import '../../profile/services/firestore_service.dart';
import '../../quiz/models/quiz_model.dart';
import '../../quiz/services/quiz_service.dart';
import '../../home/widgets/quiz_card.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _isAdmin = false;
  bool _isLoadingAdmin = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
        // Eğer admin değilse ana sayfaya yönlendir
        if (!isAdmin) {
          context.go('/');
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _isLoadingAdmin = false;
        });
        context.go('/');
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
    if (_isLoadingAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Erişim reddedildi. Admin yetkisi gerekli.')),
      );
    }

    final quizService = Provider.of<QuizService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Quiz Ekle',
            onPressed: () {
              context.go('/add-quiz');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
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
          return _buildQuizList(context, snapshot);
        },
      ),
    );
  }

  Widget _buildQuizList(BuildContext context, AsyncSnapshot<List<Quiz>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Hata: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('Henüz quiz bulunmuyor.'));
    }
    
    final filteredQuizzes = _filterQuizzes(snapshot.data!, _searchQuery);
    
    if (filteredQuizzes.isEmpty) {
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
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = filteredQuizzes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: quiz.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      quiz.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.quiz, size: 40);
                      },
                    ),
                  )
                : const Icon(Icons.quiz, size: 40),
            title: Text(quiz.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quiz.description),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text('${quiz.questions.length} soru'),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(quiz.topic),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              context.go('/admin/quiz/${quiz.id}');
            },
          ),
        );
      },
    );
  }
}
