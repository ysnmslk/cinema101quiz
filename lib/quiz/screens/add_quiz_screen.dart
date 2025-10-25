
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/question_model.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:uuid/uuid.dart';


class AddQuizScreen extends StatefulWidget {
  final Function onQuizAdded; // Quiz eklendiğinde çağrılacak fonksiyon

  const AddQuizScreen({super.key, required this.onQuizAdded});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  // Quiz ana bilgileri için denetleyiciler
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _durationController = TextEditingController();
  final _totalQuestionsController = TextEditingController();

  // Soru ve cevaplar için denetleyici listeleri
  final List<TextEditingController> _questionTextControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];
  final List<int> _correctOptionIndices = [];

  @override
  void initState() {
    super.initState();
    // Toplam soru sayısı denetleyicisine bir dinleyici ekle
    _totalQuestionsController.addListener(_updateQuestionForms);
    // Başlangıçta bir soru formu oluştur
    _addQuestionForm();
  }

  // Soru formu sayısını güncelleyen fonksiyon
  void _updateQuestionForms() {
    int newCount = int.tryParse(_totalQuestionsController.text) ?? _questionTextControllers.length;
    if (newCount <= 0) newCount = 1; // En az bir soru olmalı

    // Mevcut form sayısı ile istenen sayı arasındaki fark kadar ekle/çıkar
    while (newCount > _questionTextControllers.length) {
      _addQuestionForm();
    }
    while (newCount < _questionTextControllers.length) {
      _removeQuestionForm();
    }
    setState(() {}); // Arayüzü güncelle
  }

  // Yeni bir soru formu ve denetleyicileri ekler
  void _addQuestionForm() {
    _questionTextControllers.add(TextEditingController());
    _optionControllers.add(List.generate(4, (_) => TextEditingController()));
    _correctOptionIndices.add(0); // Varsayılan olarak ilk seçenek doğru
  }

  // Son soru formunu ve denetleyicilerini kaldırır
  void _removeQuestionForm() {
    _questionTextControllers.removeLast().dispose();
    _optionControllers.removeLast().forEach((controller) => controller.dispose());
    _correctOptionIndices.removeLast();
  }

  // Quiz'i ve soruları kaydetme fonksiyonu
  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      // 1. Quiz nesnesini oluştur
      final quiz = Quiz(
        id: _uuid.v4(), // Benzersiz ID oluştur
        title: _titleController.text,
        description: _descriptionController.text,
        imageUrl: _imageUrlController.text,
        category: _categoryController.text,
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
        totalQuestions: _questionTextControllers.length,
      );

      // 2. Question nesneleri listesini oluştur
      final List<Question> questions = [];
      for (int i = 0; i < _questionTextControllers.length; i++) {
        questions.add(Question(
          id: _uuid.v4(),
          questionText: _questionTextControllers[i].text,
          options: _optionControllers[i].map((c) => c.text).toList(),
          correctOptionIndex: _correctOptionIndices[i],
        ));
      }

      // 3. Firestore'a kaydet
      try {
        await _firestoreService.addQuizWithQuestions(quiz, questions);

        // Kullanıcıya başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onQuizAdded(); // Geri bildirim fonksiyonunu çağır
        Navigator.of(context).pop(); // Sayfayı kapat
      } catch (e) {
        // Hata durumunda kullanıcıya bilgi ver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildQuizInfoSection(),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            Text('Sorular', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ..._buildQuestionForms(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQuiz,
              child: const Text("Quiz'i Kaydet"),
            ),
          ],
        ),
      ),
    );
  }

  // Quiz'in ana bilgilerinin girildiği widget'ları oluşturan fonksiyon
  Widget _buildQuizInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Quiz Başlığı'),
          validator: (value) => value!.isEmpty ? 'Başlık boş bırakılamaz' : null,
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Açıklama'),
          validator: (value) => value!.isEmpty ? 'Açıklama boş bırakılamaz' : null,
        ),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(labelText: "Resim URL'i"),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Süre (dk)'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        TextFormField(
          controller: _totalQuestionsController,
          decoration: const InputDecoration(labelText: 'Toplam Soru Sayısı'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // Soru ve cevap formlarını dinamik olarak oluşturan fonksiyon
  List<Widget> _buildQuestionForms() {
    return List.generate(_questionTextControllers.length, (index) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Soru ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
              TextFormField(
                controller: _questionTextControllers[index],
                decoration: const InputDecoration(labelText: 'Soru Metni'),
                validator: (value) => value!.isEmpty ? 'Soru boş bırakılamaz' : null,
              ),
              const SizedBox(height: 10),
              ..._buildOptionFields(index),
            ],
          ),
        ),
      );
    });
  }

  // Her soru için cevap seçeneklerini ve doğru cevap seçimini oluşturan fonksiyon
  List<Widget> _buildOptionFields(int questionIndex) {
    return List.generate(4, (optionIndex) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _optionControllers[questionIndex][optionIndex],
              decoration: InputDecoration(labelText: 'Seçenek ${optionIndex + 1}'),
              validator: (value) => value!.isEmpty ? 'Seçenek boş bırakılamaz' : null,
            ),
          ),
          Radio<int>(
            value: optionIndex,
            groupValue: _correctOptionIndices[questionIndex],
            onChanged: (value) {
              setState(() {
                _correctOptionIndices[questionIndex] = value!;
              });
            },
          ),
          const Text('Doğru')
        ],
      );
    });
  }

  @override
  void dispose() {
    // Oluşturulan tüm denetleyicileri temizle
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    _totalQuestionsController.removeListener(_updateQuestionForms);
    _totalQuestionsController.dispose();
    for (var controller in _questionTextControllers) {
      controller.dispose();
    }
    for (var list in _optionControllers) {
      for (var controller in list) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}
