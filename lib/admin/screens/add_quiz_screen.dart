
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

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
  // --- YENİ EKLENEN CONTROLLER'LAR ---
  final _categoryController = TextEditingController();
  final _durationController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _addQuestion(); // Başlangıçta bir soru ekle
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'id': _uuid.v4(),
        'questionController': TextEditingController(),
        'optionControllers': List.generate(4, (_) => TextEditingController()),
        'correctOptionNotifier': ValueNotifier<int?>(null),
      });
    });
  }

  Future<void> _saveQuiz() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // --- HATANIN DÜZELTİLDİĞİ KISIM --- //
        final newQuiz = Quiz(
          id: _uuid.v4(),
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: _imageUrlController.text,
          category: _categoryController.text,
          // int.tryParse ile güvenli çevrim ve ?? ile varsayılan değer ataması
          durationMinutes: int.tryParse(_durationController.text) ?? 0,
          totalQuestions: _questions.length,
          questions: [], // Sorular aşağıda ayrıca işlenecek
        );

        final List<Question> questionList = [];
        for (var questionData in _questions) {
          final options = (questionData['optionControllers'] as List<TextEditingController>)
              .asMap()
              .entries
              .map((entry) {
                int idx = entry.key;
                String text = entry.value.text;
                bool isCorrect = (questionData['correctOptionNotifier'] as ValueNotifier<int?>).value == idx;
                return Option(text: text, isCorrect: isCorrect);
              })
              .toList();

          // --- HATALI PARAMETRELER TEMİZLENDİ ---
          questionList.add(Question(
            id: questionData['id'],
            text: (questionData['questionController'] as TextEditingController).text,
            options: options,
            correctAnswerIndex: (questionData['correctOptionNotifier'] as ValueNotifier<int?>).value ?? 0,
          ));
        }
        
        await _firestoreService.addQuizWithQuestions(newQuiz, questionList);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz başarıyla kaydedildi!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);

      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    // Bütün controller'ları dispose et
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    for (var q in _questions) {
      (q['questionController'] as TextEditingController).dispose();
      for (var c in (q['optionControllers'] as List<TextEditingController>)) {
        c.dispose();
      }
      (q['correctOptionNotifier'] as ValueNotifier).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
        actions: [ _isLoading ? const Padding(padding: EdgeInsets.only(right: 16.0), child: Center(child: CircularProgressIndicator(color: Colors.white))) : IconButton(icon: const Icon(Icons.save), onPressed: _saveQuiz) ],
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
            OutlinedButton.icon(icon: const Icon(Icons.add), label: const Text('Yeni Soru Ekle'), onPressed: _addQuestion),
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
        TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Quiz Başlığı', border: OutlineInputBorder()), validator: (v)=>(v==null||v.isEmpty)?'Başlık boş olamaz':null,),
        const SizedBox(height: 12),
        TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()), validator: (v)=>(v==null||v.isEmpty)?'Açıklama boş olamaz':null,),
        const SizedBox(height: 12),
        // --- YENİ EKLENEN ALANLAR ---
        TextFormField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()), validator: (v)=>(v==null||v.isEmpty)?'Kategori boş olamaz':null,),
        const SizedBox(height: 12),
        TextFormField(controller: _durationController, decoration: const InputDecoration(labelText: 'Süre (dakika)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v){ if(v==null||v.isEmpty) return 'Süre boş olamaz'; if(int.tryParse(v)==null) return 'Geçerli bir sayı girin'; return null; },),
        const SizedBox(height: 12),
        TextFormField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'Resim URL (Opsiyonel)', border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildQuestionsSection() {
    // ... Mevcut _buildQuestionsSection metodu ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sorular', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _questions.length, itemBuilder: (context, index) {
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

class _QuestionCard extends StatefulWidget {
  // ... Mevcut _QuestionCard ...
  final int questionIndex; final TextEditingController questionController; final List<TextEditingController> optionControllers; final ValueNotifier<int?> correctOptionNotifier;
  const _QuestionCard({required this.questionIndex, required this.questionController, required this.optionControllers, required this.correctOptionNotifier});
  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  // ... Mevcut _QuestionCardState ...
  int? _groupValue;
  @override
  void initState(){super.initState();_groupValue=widget.correctOptionNotifier.value;}
  @override
  Widget build(BuildContext context){
    return Card(margin:const EdgeInsets.symmetric(vertical:12),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Soru ${widget.questionIndex+1}',style:Theme.of(context).textTheme.titleLarge),
      TextFormField(controller:widget.questionController,decoration:const InputDecoration(labelText:'Soru Metni'),validator:(v)=>(v==null||v.isEmpty)?'Soru boş olamaz':null,),
      const SizedBox(height:16),
      Text('Cevap Seçenekleri',style:Theme.of(context).textTheme.titleMedium),
      ...List.generate(4,(optionIndex){
        return Row(children:[
          Radio<int>(value:optionIndex,groupValue:_groupValue,onChanged:(value){setState((){_groupValue=value;});widget.correctOptionNotifier.value=value;},),
          Expanded(child:TextFormField(controller:widget.optionControllers[optionIndex],decoration:InputDecoration(labelText:'Seçenek ${optionIndex+1}'),validator:(v)=>(v==null||v.isEmpty)?'Boş olamaz':null,),),
        ]);
      }),
      FormField<int>(builder:(state){if(widget.correctOptionNotifier.value==null&&state.hasError){return Padding(padding:const EdgeInsets.only(top:8),child:Text(state.errorText??'',style:TextStyle(color:Theme.of(context).colorScheme.error,fontSize:12),),);}return const SizedBox.shrink();},validator:(_){return widget.correctOptionNotifier.value==null?'Doğru cevabı seçin.':null;},),
    ])));
  }
}
