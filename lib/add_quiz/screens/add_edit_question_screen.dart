
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_model.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final Question? question; 

  const AddEditQuestionScreen({super.key, this.question});

  @override
  _AddEditQuestionScreenState createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionTextController;
  late List<TextEditingController> _optionControllers;
  int? _correctAnswerIndex;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController(text: widget.question?.text ?? '');
    
    // Değişiklik: Yeni soru için varsayılan olarak 4 boş seçenek oluşturuluyor.
    final options = widget.question?.options ?? List.generate(4, (_) => const Option(text: ''));
    _optionControllers = options.map((opt) => TextEditingController(text: opt.text)).toList();
    
    _correctAnswerIndex = widget.question?.correctAnswerIndex;
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      _optionControllers.removeAt(index).dispose();
      if (_correctAnswerIndex == index) {
        _correctAnswerIndex = null;
      } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
        _correctAnswerIndex = _correctAnswerIndex! - 1;
      }
    });
  }

  void _saveQuestion() {
    if (_formKey.currentState!.validate()) {
      if (_optionControllers.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az 2 seçenek ekleyin.')),
        );
        return;
      }
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen doğru cevabı seçin.')),
        );
        return;
      }

      final options = _optionControllers
          .map((controller) => Option(text: controller.text))
          .toList();
      
      final newQuestion = Question(
        text: _questionTextController.text,
        options: options,
        correctAnswerIndex: _correctAnswerIndex!,
      );

      Navigator.of(context).pop(newQuestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Yeni Soru Ekle' : 'Soruyu Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestion,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Soru Metni',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.isEmpty ? 'Soru metni boş olamaz.' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Seçenekler', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Seçenek Ekle'),
                  onPressed: _addOption,
                ),
              ],
            ),
            const Text('Doğru olanı işaretleyin', style: TextStyle(color: Colors.grey)),
            const Divider(),
            if (_optionControllers.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: Text('Lütfen seçenek ekleyin.')),
              )
            else
              ..._buildOptionFields(),
             const SizedBox(height: 30),
            ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _saveQuestion,
                label: const Text('Soruyu Kaydet'),
                 style: ElevatedButton.styleFrom(
                   padding: const EdgeInsets.symmetric(vertical: 16.0)
                 ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionFields() {
    return _optionControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Radio<int>(
              value: index,
              groupValue: _correctAnswerIndex,
              onChanged: (value) {
                setState(() {
                  _correctAnswerIndex = value;
                });
              },
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Seçenek ${index + 1}',
                  border: const OutlineInputBorder(),
                  suffixIcon: _optionControllers.length > 2 ? IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _removeOption(index),
                  ) : null,
                ),
                validator: (value) => value!.isEmpty ? 'Seçenek metni boş olamaz.' : null,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
