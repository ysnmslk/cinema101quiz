
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
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
  var _questions = <Question>[];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quiz?.title ?? '');
    _descriptionController = TextEditingController(text: widget.quiz?.description ?? '');
    _topicController = TextEditingController(text: widget.quiz?.topic ?? '');
    _durationController = TextEditingController(text: widget.quiz?.durationMinutes.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.quiz?.imageUrl ?? '');
    if (widget.quiz != null) {
      _questions = List.from(widget.quiz!.questions);
    }
  }

  @override
  Widget build(BuildContext context) {
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

  void _showAddEditQuestionDialog({Question? question, int? index}) {
    showDialog(
      context: context,
      builder: (context) => AddEditQuestionDialog(
        question: question,
        onSave: (newQuestion) {
          setState(() {
            if (index != null) {
              _questions[index] = newQuestion as Question;
            } else {
              _questions.add(newQuestion as Question);
            }
          });
        },
      ),
    );
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      final quizService = Provider.of<QuizService>(context, listen: false);
      final newQuiz = Quiz(
        id: widget.quiz?.id ?? '', // ID will be generated by Firestore for new quizzes
        title: _titleController.text,
        description: _descriptionController.text,
        topic: _topicController.text,
        durationMinutes: int.parse(_durationController.text),
        imageUrl: _imageUrlController.text,
        questions: _questions,
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
