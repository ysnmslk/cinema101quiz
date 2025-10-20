
import 'package:flutter/material.dart';
import 'package:myapp/quiz/models/question_model.dart';

class QuestionDisplay extends StatelessWidget {
  final Question question;
  final int currentQuestionIndex;
  final int totalQuestions;
  final Function(int) onAnswerSelected;
  final bool isAnswered;
  final int? selectedAnswerIndex;

  const QuestionDisplay({
    super.key,
    required this.question,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.onAnswerSelected,
    required this.isAnswered,
    required this.selectedAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Soru ${currentQuestionIndex + 1}/$totalQuestions',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ..._buildAnswerOptions(context),
        ],
      ),
    );
  }

  List<Widget> _buildAnswerOptions(BuildContext context) {
    return List.generate(question.options.length, (index) {
      final isSelected = index == selectedAnswerIndex;
      final isCorrect = index == question.correctOptionIndex;

      Color getButtonColor() {
        if (!isAnswered) return Theme.of(context).colorScheme.primary;
        if (isSelected) {
          return isCorrect ? Colors.green : Colors.red;
        } else if (isCorrect) {
          return Colors.green.withAlpha(150);
        }
        return Colors.grey;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: isAnswered ? null : () => onAnswerSelected(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: getButtonColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 18),
          ).copyWith(
            elevation: WidgetStateProperty.all(isAnswered && isSelected ? 8 : 4),
          ),
          child: Text(question.options[index]),
        ),
      );
    });
  }
}
