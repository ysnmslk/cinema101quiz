
import 'package:flutter/material.dart';
// --- DOĞRU IMPORT --- //
// Artık Question, Option gibi tüm modeller bu tek dosyadan geliyor.
import '../models/quiz_model.dart';

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
          // --- ALAN ADI GÜNCELLENDİ ---
          Text(
            question.text, // 'questionText' yerine 'text'
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
      final option = question.options[index];
      final isSelected = index == selectedAnswerIndex;
      // --- KONTROL GÜNCELLENDİ ---
      // Doğru olup olmadığını artık Option nesnesinin kendisinden öğreniyoruz.
      final bool isCorrect = option.isCorrect;

      Color? getButtonColor() {
        if (!isAnswered) return Theme.of(context).colorScheme.primary;
        if (isSelected) {
          return isCorrect ? Colors.green : Colors.red;
        } else if (isCorrect) {
          // Kullanıcı seçmedi ama doğru cevap buysa hafifçe belirt
          return Colors.green.withAlpha(150);
        }
        // Alakasız ve yanlış seçenekler
        return Colors.grey[800];
      }

      Icon? getIcon() {
        if (!isAnswered) return null;
        if (isSelected) {
          return isCorrect ? const Icon(Icons.check_circle) : const Icon(Icons.cancel);
        } else if (isCorrect) {
          return const Icon(Icons.check_circle_outline);
        }
        return null;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton.icon(
          icon: getIcon() ?? const SizedBox(width: 24), // İkon yoksa boşluk bırak
          onPressed: isAnswered ? null : () => onAnswerSelected(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: getButtonColor(),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            alignment: Alignment.centerLeft, // Metni ve ikonu sola yasla
          ).copyWith(
            elevation: WidgetStateProperty.all(isAnswered && isSelected ? 8 : 4),
          ),
          // --- TEXT GÜNCELLENDİ ---
          label: Text(option.text), // Option nesnesinin metnini kullan
        ),
      );
    });
  }
}
