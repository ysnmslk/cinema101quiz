
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/option.dart';
import 'package:myapp/quiz/models/question.dart';

class AddEditQuestionDialog extends StatefulWidget {
  final Question? question;
  final Function(Question) onSave;

  const AddEditQuestionDialog({super.key, this.question, required this.onSave});

  @override
  _AddEditQuestionDialogState createState() => _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _correctAnswerIndex = 0;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.text ?? '');
    _optionControllers = widget.question?.options
            .map((opt) => TextEditingController(text: opt.text))
            .toList() ??
        List.generate(4, (_) => TextEditingController());

    if (widget.question != null) {
      _correctAnswerIndex = widget.question!.options.indexWhere((opt) => opt.isCorrect);
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
            children: [
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(labelText: 'Soru Metni'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen soru metnini girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(labelText: 'Seçenek ${index + 1}'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen seçenek metnini girin.';
                          }
                          return null;
                        },
                      ),
                    ),
                    Radio<int>(
                      value: index,
                      groupValue: _correctAnswerIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctAnswerIndex = value!;
                        });
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveForm,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newQuestion = Question(
        id: widget.question?.id ?? DateTime.now().toString(),
        text: _questionController.text,
        options: _optionControllers.asMap().entries.map((entry) {
          return Option(
            text: entry.value.text,
            isCorrect: entry.key == _correctAnswerIndex,
          );
        }).toList(),
      );
      widget.onSave(newQuestion);
      Navigator.of(context).pop();
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
}
