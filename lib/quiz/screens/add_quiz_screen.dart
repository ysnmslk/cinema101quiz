
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/profile/services/firestore_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/question.dart' as question_model;
import 'package:myapp/quiz/models/option.dart';
import 'package:myapp/quiz/services/quiz_service.dart';
import 'package:myapp/quiz/widgets/add_edit_question_screen.dart';

class AddQuizScreen extends StatefulWidget {
  final Quiz? quiz;

  const AddQuizScreen({super.key, this.quiz});

  @override
  _AddQuizScreenState createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _topicController;
  late TextEditingController _durationController;
  late TextEditingController _imageUrlController;
  var _questions = <question_model.Question>[];
  bool _isAdmin = false;
  bool _isCheckingAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _titleController = TextEditingController(text: widget.quiz?.title ?? '');
    _descriptionController = TextEditingController(text: widget.quiz?.description ?? '');
    _topicController = TextEditingController(text: widget.quiz?.topic ?? '');
    _durationController = TextEditingController(text: widget.quiz?.durationMinutes.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.quiz?.imageUrl ?? '');
    if (widget.quiz != null) {
      // Convert quiz_model.Question to question_model.Question
      _questions = widget.quiz!.questions.map((q) {
        // Find correct answer index
        int? correctIndex;
        if (q.correctAnswerIndex != null && q.options.isNotEmpty) {
          correctIndex = q.correctAnswerIndex;
        }
        // Convert options to Option
        final options = q.options.asMap().entries.map((entry) {
          return Option(
            text: entry.value.toString(),
            isCorrect: entry.key == correctIndex,
          );
        }).toList();
        return question_model.Question(
          id: q.id,
          text: q.text,
          options: options,
        );
      }).toList();
    }
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
          _isCheckingAdmin = false;
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
          _isCheckingAdmin = false;
        });
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Admin kontrolü yapılıyorsa loading göster
    if (_isCheckingAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Admin değilse erişim reddedildi mesajı göster
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erişim Reddedildi'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Bu sayfaya erişim yetkiniz yok.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Sadece admin kullanıcılar quiz ekleyebilir.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz == null ? 'Yeni Quiz Ekle' : 'Quizi Düzenle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                  validator: (value) => value!.isEmpty ? 'Lütfen başlık girin.' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  validator: (value) => value!.isEmpty ? 'Lütfen açıklama girin.' : null,
                ),
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'Konu'),
                  validator: (value) => value!.isEmpty ? 'Lütfen konu girin.' : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Süre (dakika)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Lütfen süre girin.' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: "Görsel URL'si"),
                  validator: (value) => value!.isEmpty ? "Lütfen görsel URL'si girin." : null,
                ),
                const SizedBox(height: 20),
                _buildQuestionsList(context),
                ElevatedButton(
                  onPressed: _saveQuiz,
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sorular', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditQuestionDialog(),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final question = _questions[index];
            return ListTile(
              title: Text(question.text),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showAddEditQuestionDialog(question: question, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _questions.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddEditQuestionDialog({question_model.Question? question, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AddEditQuestionDialog(
        question: question,
        onSave: (newQuestion) {
          setState(() {
            if (index != null) {
              _questions[index] = newQuestion;
            } else {
              _questions.add(newQuestion);
            }
          });
        },
      ),
    );
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      final quizService = Provider.of<QuizService>(context, listen: false);
      // Convert question_model.Question to quiz_model.Question
      final quizQuestions = _questions.map((q) {
        // Find correct answer index
        int? correctIndex;
        for (int i = 0; i < q.options.length; i++) {
          if (q.options[i].isCorrect) {
            correctIndex = i;
            break;
          }
        }
        return Question(
          id: q.id,
          text: q.text,
          options: q.options.map((opt) => opt.text).toList(),
          correctAnswerIndex: correctIndex,
        );
      }).toList();
      
      final newQuiz = Quiz(
        id: widget.quiz?.id ?? '', // ID will be generated by Firestore for new quizzes
        title: _titleController.text,
        description: _descriptionController.text,
        topic: _topicController.text,
        durationMinutes: int.parse(_durationController.text),
        imageUrl: _imageUrlController.text,
        questions: quizQuestions,
      );

      if (widget.quiz == null) {
        quizService.addQuiz(newQuiz);
      } else {
        quizService.updateQuiz(newQuiz);
      }

      Navigator.of(context).pop();
    }
  }
}
