
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/question_model.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _addQuestion();
  }

  void _addQuestion() {
    setState(() {
      final questionController = TextEditingController();
      final optionControllers = List.generate(4, (_) => TextEditingController());
      final correctOptionNotifier = ValueNotifier<int?>(null);

      _questions.add({
        'questionController': questionController,
        'optionControllers': optionControllers,
        'correctOptionNotifier': correctOptionNotifier,
      });
    });
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final newQuiz = Quiz(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          questions: [],
        );

        final List<Question> questionList = [];
        for (var questionData in _questions) {
          final options = (questionData['optionControllers'] as List<TextEditingController>)
              .map((c) => c.text)
              .toList();

          questionList.add(Question(
            id: '',
            questionText: (questionData['questionController'] as TextEditingController).text,
            options: options,
            correctOptionIndex: (questionData['correctOptionNotifier'] as ValueNotifier<int?>).value!,
          ));
        }
        
        await _firestoreService.addQuizWithQuestions(newQuiz, questionList);

        if (!mounted) return;
        Navigator.of(context).pop(true);

      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm zorunlu alanları doldurun.')),
        );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    for (var questionData in _questions) {
      questionData['questionController'].dispose();
      for (var controller in questionData['optionControllers']) {
        controller.dispose();
      }
      questionData['correctOptionNotifier'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveQuiz,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildQuizDetailsSection(),
            const SizedBox(height: 24),
            _buildQuestionsSection(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Yeni Soru Ekle'),
              onPressed: _addQuestion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quiz Detayları', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Quiz Başlığı', border: OutlineInputBorder()),
          validator: (value) => (value == null || value.isEmpty) ? 'Başlık boş olamaz' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
           validator: (value) => (value == null || value.isEmpty) ? 'Açıklama boş olamaz' : null,
        ),
         const SizedBox(height: 12),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(labelText: 'Resim URL (Opsiyonel)', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sorular', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _questions.length,
          itemBuilder: (context, index) {
            final questionData = _questions[index];
            return _QuestionCard(
              questionIndex: index,
              questionController: questionData['questionController'],
              optionControllers: questionData['optionControllers'],
              correctOptionNotifier: questionData['correctOptionNotifier'],
            );
          },
        ),
      ],
    );
  }
}


// Her bir soru kartını yöneten yeni StatefulWidget
class _QuestionCard extends StatefulWidget {
  final int questionIndex;
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  final ValueNotifier<int?> correctOptionNotifier;

  const _QuestionCard({
    required this.questionIndex,
    required this.questionController,
    required this.optionControllers,
    required this.correctOptionNotifier,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  int? _groupValue;

  @override
  void initState() {
    super.initState();
    _groupValue = widget.correctOptionNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Soru ${widget.questionIndex + 1}', style: Theme.of(context).textTheme.titleLarge),
            TextFormField(
              controller: widget.questionController,
              decoration: const InputDecoration(labelText: 'Soru Metni'),
              validator: (value) => (value == null || value.isEmpty) ? 'Soru metni boş olamaz' : null,
            ),
            const SizedBox(height: 16),
            Text('Cevap Seçenekleri (Doğru olanı işaretleyin)', style: Theme.of(context).textTheme.titleMedium),
            ...List.generate(4, (optionIndex) {
              return Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    // Artık groupValue doğrudan state'ten geliyor.
                    // ignore: deprecated_member_use
                    groupValue: _groupValue,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() {
                        _groupValue = value;
                      });
                      // Ana listedeki notifier'ı da güncellemeye devam ediyoruz.
                      widget.correctOptionNotifier.value = value;
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: widget.optionControllers[optionIndex],
                      decoration: InputDecoration(labelText: 'Seçenek ${optionIndex + 1}'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Seçenek boş olamaz' : null,
                    ),
                  ),
                ],
              );
            }),
            FormField<int>(
              builder: (state) {
                 if (widget.correctOptionNotifier.value == null && state.hasError) {
                   return Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(
                       state.errorText ?? '',
                       style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                     ),
                   );
                }
                return const SizedBox.shrink();
              },
               validator: (_) {
                return widget.correctOptionNotifier.value == null ? 'Lütfen bir doğru cevap seçin.' : null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
