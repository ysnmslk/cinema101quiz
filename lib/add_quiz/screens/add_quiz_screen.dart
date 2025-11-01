
import 'package:flutter/material.dart';
import 'package:myapp/add_quiz/screens/add_edit_question_screen.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _durationController = TextEditingController();

  final List<Question> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    _imageUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _navigateToAddQuestion() async {
    final newQuestion = await Navigator.of(context).push<Question>(
      MaterialPageRoute(
        builder: (context) => const AddEditQuestionScreen(),
      ),
    );

    if (newQuestion != null && mounted) {
      setState(() {
        _questions.add(newQuestion);
      });
    }
  }

  void _navigateToEditQuestion(int index) async {
    final editedQuestion = await Navigator.of(context).push<Question>(
      MaterialPageRoute(
        builder: (context) => AddEditQuestionScreen(question: _questions[index]),
      ),
    );

    if (editedQuestion != null && mounted) {
      setState(() {
        _questions[index] = editedQuestion;
      });
    }
  }
  
  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }


  void _submitForm() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      _formKey.currentState!.save();

      final newQuiz = Quiz(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        topic: _topicController.text,
        imageUrl: _imageUrlController.text,
        durationMinutes: int.tryParse(_durationController.text) ?? 10,
        questions: _questions,
        createdAt: Timestamp.now(),
      );

      try {
        await _firestoreService.addQuiz(newQuiz);
        messenger.showSnackBar(
          const SnackBar(content: Text('Quiz başarıyla eklendi!')),
        );
        navigator.pop();
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } else if (_questions.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir soru ekleyin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Başlık boş olamaz' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Açıklama boş olamaz' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Konu', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Konu boş olamaz' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Resim URL', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Resim URL\'si boş olamaz' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Süre (dakika)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Süre boş olamaz' : null,
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sorular (${_questions.length})', style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Soru Ekle'),
                  ),
                ],
              ),
              if (_questions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(child: Text('Henüz soru eklenmedi.')),
                )
              else
                _buildQuestionsList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom( // Düzeltildi: styleFrom
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Quiz\'i Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        final question = _questions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis,),
            subtitle: Text('${question.options.length} seçenek'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _navigateToEditQuestion(index),
                  tooltip: 'Düzenle',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteQuestion(index),
                  tooltip: 'Sil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
