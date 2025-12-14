import 'package:flutter/material.dart';
import '../../quiz/models/quiz_model.dart';

class QuestionEditor extends StatefulWidget {
  final Question question;
  final Function(Question) onSave;

  const QuestionEditor({
    super.key,
    required this.question,
    required this.onSave,
  });

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController _textController;
  late List<TextEditingController> _optionControllers;
  late int? _correctAnswerIndex;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _optionControllers = widget.question.options.map((opt) {
      return TextEditingController(text: opt.toString());
    }).toList();
    _correctAnswerIndex = widget.question.correctAnswerIndex;
  }

  @override
  void dispose() {
    _textController.dispose();
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
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
        if (_correctAnswerIndex == index) {
          _correctAnswerIndex = null;
        } else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
          _correctAnswerIndex = _correctAnswerIndex! - 1;
        }
      });
    }
  }

  void _save() {
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen soru metnini girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az 2 seçenek olmalıdır'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_correctAnswerIndex == null || _correctAnswerIndex! >= options.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen doğru cevabı seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedQuestion = Question(
      id: widget.question.id,
      text: _textController.text.trim(),
      options: options,
      correctAnswerIndex: _correctAnswerIndex,
    );

    widget.onSave(updatedQuestion);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Soru güncellendi'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Soru metni
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Soru Metni',
            border: OutlineInputBorder(),
            hintText: 'Soruyu buraya yazın...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        
        // Seçenekler
        Text(
          'Seçenekler',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...List.generate(_optionControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Radio<int?>(
                  value: index,
                  groupValue: _correctAnswerIndex,
                  onChanged: (value) {
                    setState(() {
                      _correctAnswerIndex = value;
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _optionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Seçenek ${index + 1}',
                      border: const OutlineInputBorder(),
                      suffixIcon: _optionControllers.length > 2
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeOption(index),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        
        // Seçenek ekle butonu
        OutlinedButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Seçenek Ekle'),
        ),
        const SizedBox(height: 16),
        
        // Kaydet butonu
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Değişiklikleri Kaydet'),
        ),
      ],
    );
  }
}
