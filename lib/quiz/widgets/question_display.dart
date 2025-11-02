
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/quiz_models.dart';

class QuestionDisplay extends StatelessWidget {
  final Question question;
  final int? selectedOptionIndex;
  final ValueChanged<int> onAnswerSelected;

  const QuestionDisplay({
    super.key,
    required this.question,
    required this.selectedOptionIndex,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...List.generate(question.options.length, (index) {
          final option = question.options[index];
          final bool isSelected = selectedOptionIndex == index;

          return Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
            child: ListTile(
              onTap: () => onAnswerSelected(index),
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C...
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              title: Text(option.text),
            ),
          );
        }),
      ],
    );
  }
}
