import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../auth/services/auth_service.dart';
import '../../profile/services/firestore_service.dart';
import '../../quiz/models/quiz_model.dart';
import '../../quiz/services/quiz_service.dart';
import '../widgets/question_editor.dart';

class AdminQuizDetailScreen extends StatefulWidget {
  final String quizId;

  const AdminQuizDetailScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<AdminQuizDetailScreen> createState() => _AdminQuizDetailScreenState();
}

class _AdminQuizDetailScreenState extends State<AdminQuizDetailScreen> {
  bool _isAdmin = false;
  bool _isLoadingAdmin = true;
  bool _isLoadingQuiz = true;
  Quiz? _quiz;
  bool _isSaving = false;

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
        if (isAdmin) {
          _loadQuiz();
        } else {
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

  Future<void> _loadQuiz() async {
    final quizService = Provider.of<QuizService>(context, listen: false);
    final quiz = await quizService.getQuizById(widget.quizId);
    if (mounted) {
      setState(() {
        _quiz = quiz;
        _isLoadingQuiz = false;
      });
    }
  }

  Future<void> _saveQuiz() async {
    if (_quiz == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final quizService = Provider.of<QuizService>(context, listen: false);
      await quizService.updateQuiz(_quiz!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _addQuestion() {
    if (_quiz == null) return;

    final newQuestion = Question(
      id: const Uuid().v4(),
      text: 'Yeni soru',
      options: ['Seçenek 1', 'Seçenek 2', 'Seçenek 3', 'Seçenek 4'],
      correctAnswerIndex: 0,
    );

    setState(() {
      _quiz = Quiz(
        id: _quiz!.id,
        title: _quiz!.title,
        description: _quiz!.description,
        topic: _quiz!.topic,
        durationMinutes: _quiz!.durationMinutes,
        imageUrl: _quiz!.imageUrl,
        questions: [..._quiz!.questions, newQuestion],
        createdAt: _quiz!.createdAt,
      );
    });
  }

  void _deleteQuestion(int index) {
    if (_quiz == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soru Sil'),
        content: const Text('Bu soruyu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final newQuestions = List<Question>.from(_quiz!.questions);
                newQuestions.removeAt(index);
                _quiz = Quiz(
                  id: _quiz!.id,
                  title: _quiz!.title,
                  description: _quiz!.description,
                  topic: _quiz!.topic,
                  durationMinutes: _quiz!.durationMinutes,
                  imageUrl: _quiz!.imageUrl,
                  questions: newQuestions,
                  createdAt: _quiz!.createdAt,
                );
              });
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _updateQuestion(int index, Question updatedQuestion) {
    if (_quiz == null) return;

    setState(() {
      final newQuestions = List<Question>.from(_quiz!.questions);
      newQuestions[index] = updatedQuestion;
      _quiz = Quiz(
        id: _quiz!.id,
        title: _quiz!.title,
        description: _quiz!.description,
        topic: _quiz!.topic,
        durationMinutes: _quiz!.durationMinutes,
        imageUrl: _quiz!.imageUrl,
        questions: newQuestions,
        createdAt: _quiz!.createdAt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingAdmin || _isLoadingQuiz) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text('Erişim reddedildi. Admin yetkisi gerekli.')),
      );
    }

    if (_quiz == null) {
      return const Scaffold(
        body: Center(child: Text('Quiz bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz!.title),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Kaydet',
              onPressed: _saveQuiz,
            ),
        ],
      ),
      body: Column(
        children: [
          // Quiz bilgileri
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _quiz!.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text('${_quiz!.questions.length} soru'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_quiz!.topic),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${_quiz!.durationMinutes} dakika'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Soru listesi
          Expanded(
            child: _quiz!.questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz soru eklenmemiş',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quiz!.questions.length,
                    itemBuilder: (context, index) {
                      final question = _quiz!.questions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            question.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${question.options.length} seçenek • Doğru cevap: ${question.correctAnswerIndex != null && question.correctAnswerIndex! < question.options.length ? question.options[question.correctAnswerIndex!].toString() : 'Belirtilmemiş'}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQuestion(index),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: QuestionEditor(
                                question: question,
                                onSave: (updatedQuestion) {
                                  _updateQuestion(index, updatedQuestion);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Soru Ekle'),
      ),
    );
  }
}
