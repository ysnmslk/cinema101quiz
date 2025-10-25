
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
// question_model.dart'ı import etmeye artık gerek yok çünkü quiz_model.dart içinde hepsi birleşti.
import 'package:uuid/uuid.dart';
import 'package:myapp/quiz/services/firestore_service.dart'; // Firestore servisini import edelim

class AddQuizScreen extends StatefulWidget {
  // onQuizAdded callback'ine artık gerek yok, işlemi burada yapacağız.
  const AddQuizScreen({super.key});

  @override
  _AddQuizScreenState createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService(); // Servis örneği
  
  String _title = '';
  String _description = '';
  String _category = '';
  int _durationMinutes = 10;
  int _totalQuestions = 1;

  String? _imageUrl;
  final List<Question> _questions = [];

  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  bool _isLoading = false; // Yüklenme durumu için state

  @override
  void initState() {
    super.initState();
    _addQuestionForm();
  }

  // --- HATANIN ÇÖZÜLDÜĞÜ YER --- //
  void _addQuestionForm() {
    setState(() {
      _questions.add(Question(
        id: _uuid.v4(),
        text: '',
        options: List.generate(4, (_) => Option(text: '')),
        // Sadece gerekli ve doğru parametreler kullanılıyor.
        // Varsayılan olarak ilk seçenek (index 0) doğru kabul ediliyor.
        correctAnswerIndex: 0,
      ));
    });
  }

  void _updateQuestionCount() {
    while (_questions.length < _totalQuestions) {
      _addQuestionForm();
    }
    while (_questions.length > _totalQuestions) {
      setState(() {
        _questions.removeLast();
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64Image = 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
      setState(() {
        _imageUrl = base64Image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir kapak resmi seçin.')),
        );
        return;
      }
      
      for (var q in _questions) {
        if (q.options.any((opt) => opt.text.trim().isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${q.text.isNotEmpty ? q.text : 'İsimsiz Soru'}" içindeki boş seçenekleri doldurun.')),
          );
          return;
        }
      }
      
      setState(() {
        _isLoading = true; // Yükleniyor... olarak ayarla
      });

      final newQuiz = Quiz(
        id: _uuid.v4(),
        title: _title,
        description: _description,
        imageUrl: _imageUrl!,
        category: _category,
        durationMinutes: _durationMinutes,
        totalQuestions: _totalQuestions,
        questions: _questions, // Soruları da ekleyelim
      );

      try {
        await _firestoreService.addQuizWithQuestions(newQuiz, _questions);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz başarıyla eklendi!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Geri dön ve ana sayfayı yenile
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false; // İşlem bitti
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Quiz Ekle')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ... Diğer form alanları ...
                  TextFormField(decoration: const InputDecoration(labelText: 'Başlık'), validator: (v)=>(v==null||v.isEmpty)?'Gerekli':null, onSaved: (v)=>_title=v!,),
                  TextFormField(decoration: const InputDecoration(labelText: 'Açıklama'), validator: (v)=>(v==null||v.isEmpty)?'Gerekli':null, onSaved: (v)=>_description=v!,),
                  TextFormField(decoration: const InputDecoration(labelText: 'Kategori'), validator: (v)=>(v==null||v.isEmpty)?'Gerekli':null, onSaved: (v)=>_category=v!,),
                  TextFormField(decoration: const InputDecoration(labelText: 'Süre (dakika)'), keyboardType: TextInputType.number, initialValue: _durationMinutes.toString(), validator: (v)=>(v==null||v.isEmpty||int.tryParse(v)==null)?'Geçerli sayı girin':null, onChanged: (v)=>setState(()=>_durationMinutes=int.tryParse(v)??10),),
                  TextFormField(decoration: const InputDecoration(labelText: 'Soru Sayısı'), keyboardType: TextInputType.number, initialValue: _totalQuestions.toString(), validator: (v)=>(v==null||v.isEmpty||int.tryParse(v)==null||int.parse(v)<1)?'En az 1 soru':null, onChanged: (v){setState((){_totalQuestions=int.tryParse(v)??1; _updateQuestionCount();});},),
                  const SizedBox(height: 20),
                  _buildImagePreview(),
                  ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Kapak Resmi Seç')),
                  const Divider(height: 40),
                  Text('Sorular', style: Theme.of(context).textTheme.headlineSmall),
                  ..._buildQuestionForms(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm, // Yükleniyorsa butonu pasif yap
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Quiz'i Kaydet"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
     if (_imageUrl == null) {
      return Container(height: 150, width: double.infinity, color: Colors.grey[200], child: const Center(child: Text('Kapak Resmi Seçilmedi')));
    }
    final imageBytes = base64Decode(_imageUrl!.split(',').last);
    return Image.memory(imageBytes, height: 150, width: double.infinity, fit: BoxFit.cover);
  }

  List<Widget> _buildQuestionForms() {
    return _questions.asMap().entries.map((entry) {
      int index = entry.key;
      Question question = entry.value;
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Soru ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(initialValue: question.text, decoration: const InputDecoration(labelText: 'Soru Metni'), validator: (v)=>(v==null||v.isEmpty)?'Soru boş olamaz':null, onSaved: (v)=>question.text=v!, onChanged: (v)=>question.text=v,),
              const SizedBox(height: 10),
              Text('Seçenekler (Biri doğru olmalı)', style: Theme.of(context).textTheme.titleMedium),
              ...question.options.asMap().entries.map((optionEntry) {
                int optionIndex = optionEntry.key;
                return Row(
                  children: [
                    Radio<int>(value: optionIndex, groupValue: question.correctAnswerIndex, onChanged: (int? value){setState((){question.correctAnswerIndex = value!;});},),
                    Expanded(child: TextFormField(initialValue: optionEntry.value.text, decoration: InputDecoration(labelText: 'Seçenek ${optionIndex + 1}'), validator: (v)=>(v==null||v.isEmpty)?'Boş olamaz':null, onSaved: (v)=>optionEntry.value.text = v!,),),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      );
    }).toList();
  }
}
