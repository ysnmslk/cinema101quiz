
import 'package:flutter/material.dart';
import 'package:myapp/add_quiz/screens/add_edit_question_screen.dart';
import 'package:myapp/quiz/models/quiz_models.dart';
import 'package:myapp/firestore_service.dart';
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

  void _navigateAndAddQuestion() async {
    final newQuestion = await showAddEditQuestionDialog(context);

    if (newQuestion != null && mounted) {
      setState(() {
        _questions.add(newQuestion);
      });
    }
  }

  void _editQuestion(int index) async {
    final updatedQuestion = await showAddEditQuestionDialog(
      context,
      question: _questions[index],
    );

    if (updatedQuestion != null && mounted) {
      setState(() {
        _questions[index] = updatedQuestion;
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  void _submitQuiz() async {
    if (_formKey.currentState!.validate()) {
      if (_questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir soru ekleyin.')),
        );
        return;
      }

      final quiz = Quiz(
        id: '', // Firestore oluşturacak
        title: _titleController.text,
        description: _descriptionController.text,
        topic: _topicController.text,
        imageUrl: _imageUrlController.text.isNotEmpty 
            ? _imageUrlController.text 
            : 'https://firebasestorage.googleapis.com/v0/b/quiz-app-ca957.appspot.com/o/images%2Fplaceholder.png?alt=media&token=85333555-3224-47c3-a0a3-4061e479c3d7',
        durationMinutes: int.tryParse(_durationController.text) ?? 10,
        createdAt: Timestamp.now(),
      );

      try {
        await _firestoreService.createQuiz(quiz, _questions);
        
        // Düzeltme: `mounted` kontrolü eklendi.
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz başarıyla oluşturuldu!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        // Düzeltme: `mounted` kontrolü eklendi.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Oluştur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitQuiz,
            tooltip: "Quiz'i Kaydet",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_titleController, 'Başlık'),
                _buildTextField(_descriptionController, 'Açıklama'),
                _buildTextField(_topicController, 'Konu (örn: Tarih)'),
                _buildTextField(_imageUrlController, 'Resim URL (isteğe bağlı)'),
                _buildTextField(_durationController, 'Süre (dakika)', keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                _buildQuestionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (controller != _imageUrlController && (value == null || value.isEmpty)) {
            return '$label boş olamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Sorular', style: Theme.of(context).textTheme.headlineSmall),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Soru Ekle'),
              onPressed: _navigateAndAddQuestion,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_questions.isEmpty)
          const Center(child: Text('Henüz soru eklenmedi.'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(_questions[index].text),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editQuestion(index)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeQuestion(index)),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
