
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/option.dart';
import 'package:myapp/quiz/models/quiz_model.dart';


Future<Question?> showAddEditQuestionDialog(
  BuildContext context, {
  Question? question,
}) {
  return showDialog<Question?>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddEditQuestionDialog(question: question),
  );
}

class AddEditQuestionDialog extends StatefulWidget {
  final Question? question;

  const AddEditQuestionDialog({super.key, this.question});

  @override
  State<AddEditQuestionDialog> createState() => _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int? _selectedCorrectIndex;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.text ?? '');
    
    final options = widget.question?.options;
    if (options != null && options.isNotEmpty) {
      _optionControllers = options
          .map((opt) => TextEditingController(text: opt.text))
          .toList();
      final correctIndex = options.indexWhere((opt) => opt.isCorrect);
      if (correctIndex != -1) {
        _selectedCorrectIndex = correctIndex;
      }
    } else {
      _optionControllers = List.generate(4, (_) => TextEditingController());
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCorrectIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen doğru cevabı işaretleyin.')),
        );
        return;
      }

      final validOptions = _optionControllers
          .where((controller) => controller.text.trim().isNotEmpty)
          .toList();

      if (validOptions.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az 2 geçerli seçenek girin.')),
        );
        return;
      }

      final options = List<Option>.generate(validOptions.length, (index) {
        final originalController = validOptions[index];
        final originalIndex = _optionControllers.indexOf(originalController);
        return Option(
          text: originalController.text,
          isCorrect: originalIndex == _selectedCorrectIndex,
        );
      });

      final newQuestion = Question(
        id: widget.question?.id ?? '',
        text: _questionController.text,
        options: options,
         correctAnswerIndex: null,
      );
      Navigator.of(context).pop(newQuestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.question == null ? 'Yeni Soru Ekle' : 'Soruyu Düzenle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Soru Metni'),
                validator: (value) => value!.isEmpty ? 'Soru boş olamaz' : null,
              ),
              const SizedBox(height: 20),
              Text('Seçenekler (Doğru olanı işaretleyin)', style: Theme.of(context).textTheme.titleMedium),
              ..._buildOptionFields(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
        ElevatedButton(onPressed: _saveForm, child: const Text('Kaydet')),
      ],
    );
  }

  List<Widget> _buildOptionFields() {
    return List<Widget>.generate(_optionControllers.length, (index) {
      return Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: _selectedCorrectIndex,
            onChanged: (int? value) {
              setState(() {
                _selectedCorrectIndex = value;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: _optionControllers[index],
              decoration: InputDecoration(labelText: 'Seçenek ${index + 1}'),
            ),
          ),
        ],
      );
    });
  }
}
