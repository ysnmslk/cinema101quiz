
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

import 'package:myapp/quiz/services/firestore_service.dart';

import '../../quiz/widgets/quiz_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Quiz> _searchResults = [];
  List<Quiz> _allQuizzes = [];

  @override
  void initState() {
    super.initState();
    _loadAllQuizzes();
    _searchController.addListener(_filterQuizzes);
  }

  Future<void> _loadAllQuizzes() async {
    try {
      final quizzes = await _firestoreService.getQuizzes();
      if (mounted) {
        setState(() {
          _allQuizzes = quizzes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quizler yüklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  void _filterQuizzes() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final filteredList = _allQuizzes.where((quiz) {
      final titleLower = quiz.title.toLowerCase();
      final descriptionLower = quiz.description.toLowerCase();
      return titleLower.contains(query) || descriptionLower.contains(query);
    }).toList();

    setState(() => _searchResults = filteredList);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterQuizzes);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Film adı veya açıklama ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
        return const Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Icon(Icons.search, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aramak için yukarıdaki alana yazın.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
            ),
        );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('Arama sonucu bulunamadı.', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return QuizCard(quiz: _searchResults[index]);
      },
    );
  }
}
