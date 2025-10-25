
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart' as quiz_models;
import 'package:myapp/quiz/services/firestore_service.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Quiz ana bilgileri için denetleyiciler
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageUrlController;

  // Soruları ve seçeneklerini yönetmek için listeler
  final List<TextEditingController> _questionControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];
  final List<ValueNotifier<int?>> _correctOptionNotifiers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _categoryController = TextEditingController();
    _imageUrlController = TextEditingController();
    _addQuestion(); // Başlangıçta bir soru ekle
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    for (var controllers in _optionControllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    for (var notifier in _correctOptionNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questionControllers.add(TextEditingController());
      _optionControllers.add(
        List.generate(4, (_) => TextEditingController()),
      );
      _correctOptionNotifiers.add(ValueNotifier<int?>(null));
    });
  }

  void _removeQuestion(int index) {
    // Formun durumunu kaybetmemek için bir sonraki frame'de silme yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
         if (index < _questionControllers.length) {
            _questionControllers[index].dispose();
            _questionControllers.removeAt(index);
        }
        if (index < _optionControllers.length) {
            for (var controller in _optionControllers[index]) {
                controller.dispose();
            }
            _optionControllers.removeAt(index);
        }
        if (index < _correctOptionNotifiers.length) {
            _correctOptionNotifiers[index].dispose();
            _correctOptionNotifiers.removeAt(index);
        }
      });
    });
  }


  Future<void> _saveQuiz() async {
    // Önce notifier'lardaki null değerleri kontrol et ve formu validate et
    for (var notifier in _correctOptionNotifiers) {
      if (notifier.value == null) {
        // Bu, gizli FormField'ın validator'ını tetikleyecektir.
        _formKey.currentState!.validate();
        return; // Bir seçim yapılmadıysa kaydetme
      }
    }

    if (_formKey.currentState!.validate()) {
      final newQuiz = quiz_models.Quiz(
        // ID'ler Firestore servisi tarafından atanacak, burada boş bırak
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        imageUrl: _imageUrlController.text,
        durationMinutes: 0, // Varsayılan değer, isterseniz bunu da bir alan yapabilirsiniz
        questions: List.generate(_questionControllers.length, (qIndex) {
          final correctIndex = _correctOptionNotifiers[qIndex].value!;
          return quiz_models.Question(
            text: _questionControllers[qIndex].text,
            options: List.generate(4, (oIndex) {
              return quiz_models.Option(
                text: _optionControllers[qIndex][oIndex].text,
                isCorrect: oIndex == correctIndex, // toMap içinde de ayarlanıyor ama burada olması daha net
              );
            }),
            correctAnswerIndex: correctIndex,
          );
        }),
      );

      try {
        // --- DOĞRU METOT ÇAĞRISI --- //
        await _firestoreService.addQuiz(newQuiz);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz başarıyla kaydedildi!')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz kaydedilirken bir hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuiz,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildQuizInfoSection(),
            const SizedBox(height: 24),
            Text('Sorular', style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            ..._buildQuestionList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Soru Ekle'),
                onPressed: _addQuestion,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Quiz Başlığı'),
          validator: (v) => (v == null || v.isEmpty) ? 'Başlık boş olamaz' : null,
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Açıklama'),
          validator: (v) => (v == null || v.isEmpty) ? 'Açıklama boş olamaz' : null,
        ),
        TextFormField(
          controller: _categoryController,
          decoration: const InputDecoration(labelText: 'Kategori (Örn: Film, Bilim)'),
          validator: (v) => (v == null || v.isEmpty) ? 'Kategori boş olamaz' : null,
        ),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(labelText: 'Görsel URL (opsiyonel)'),
        ),
      ],
    );
  }

  List<Widget> _buildQuestionList() {
    return List.generate(_questionControllers.length, (index) {
      return _QuestionCard(
        key: ObjectKey(_questionControllers[index]), // Stabil key
        questionIndex: index,
        questionController: _questionControllers[index],
        optionControllers: _optionControllers[index],
        correctOptionNotifier: _correctOptionNotifiers[index],
        onRemove: () => _removeQuestion(index),
      );
    });
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionIndex;
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  final ValueNotifier<int?> correctOptionNotifier;
  final VoidCallback onRemove;

  const _QuestionCard({
    super.key,
    required this.questionIndex,
    required this.questionController,
    required this.optionControllers,
    required this.correctOptionNotifier,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Soru ${questionIndex + 1}', style: Theme.of(context).textTheme.titleLarge),
                 // Silme butonunu her zaman göster ama ilk soru için devre dışı bırak
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
            TextFormField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Soru Metni'),
              validator: (v) => (v == null || v.isEmpty) ? 'Soru boş olamaz' : null,
            ),
            const SizedBox(height: 16),
            Text('Cevap Seçenekleri (Doğru olanı işaretleyin)', style: Theme.of(context).textTheme.titleMedium),
            ValueListenableBuilder<int?>(
              valueListenable: correctOptionNotifier,
              builder: (context, groupValue, child) {
                return Column(
                  children: List.generate(4, (optionIndex) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: optionIndex,
                          // ignore: deprecated_member_use
                          groupValue: groupValue,
                          // ignore: deprecated_member_use
                          onChanged: (value) {
                            correctOptionNotifier.value = value;
                          },
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: optionControllers[optionIndex],
                            decoration: InputDecoration(labelText: 'Seçenek ${optionIndex + 1}'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Seçenek boş olamaz' : null,
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
            
            // --- HATANIN ÇÖZÜLDÜĞÜ YER --- //
            // FormField artık null olabilen bir int (int?) bekliyor.
            FormField<int?>(
              // notifier değiştikçe yeniden doğrulama yapması için key
              key: ValueKey('formfield_validator_$questionIndex'),
              initialValue: correctOptionNotifier.value, // başlangıç değeri
              validator: (value) {
                // Değer null ise hata mesajı döndür
                if (correctOptionNotifier.value == null) {
                  return 'Lütfen bu soru için doğru cevabı seçin.';
                }
                return null; // Her şey yolundaysa null döndür
              },
              builder: (state) {
                // Hata varsa, metni göster
                if (state.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink(); // Hata yoksa boşluk göster
              },
            ),
          ],
        ),
      ),
    );
  }
}
