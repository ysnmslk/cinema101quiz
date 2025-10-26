
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth import edildi
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/firestore_service.dart';

class QuizResults extends StatefulWidget {
  final Quiz quiz;
  final int score;
  final List<int> userAnswers;
  final VoidCallback onRestartQuiz;

  const QuizResults({
    super.key,
    required this.quiz,
    required this.score,
    required this.userAnswers,
    required this.onRestartQuiz,
  });

  @override
  State<QuizResults> createState() => _QuizResultsState();
}

class _QuizResultsState extends State<QuizResults> {
  @override
  void initState() {
    super.initState();
    // Sonucu kaydetmek için bir frame beklendikten sonra çağrılır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResult();
    });
  }

  // AppAuthProvider yerine doğrudan FirebaseAuth kullanır
  Future<void> _saveResult() async {
    final firestoreService = FirestoreService();
    final user = FirebaseAuth.instance.currentUser; // Kullanıcıyı doğrudan al

    if (user == null) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sonuçları kaydetmek için giriş yapmalısınız.')),
        );
      }
      return;
    }

    final newResult = QuizResult(
      userId: user.uid,
      quizId: widget.quiz.id,
      score: widget.score,
      totalQuestions: widget.quiz.questions.length,
      timestamp: Timestamp.now(),
      userAnswers: widget.userAnswers, // Kullanıcının cevaplarını kaydet
      quizTitle: widget.quiz.title,
      quizImageUrl: widget.quiz.imageUrl,
    );

    try {
      await firestoreService.saveQuizResult(newResult);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: Sonucunuz kaydedilemedi. $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = widget.quiz.questions.length;
    final double percentage = totalQuestions > 0 ? (widget.score / totalQuestions) * 100 : 0;

    String getResultMessage() {
      if (percentage >= 80) {
        return "Harika İş! Sinema dahisisin!";
      } else if (percentage >= 50) {
        return "İyi iş! Gelişiyorsun!";
      } else {
        return "Biraz daha pratik yapmaya ne dersin?";
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Quiz Bitti!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(getResultMessage(), style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('Sonucun: ${widget.score}/$totalQuestions', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          Text('Başarı Oranı: ${percentage.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: widget.onRestartQuiz, child: const Text('Tekrar Dene')),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Ana Menüye Dön')),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Text("Cevapların", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalQuestions,
            itemBuilder: (context, index) {
              final question = widget.quiz.questions[index];
              final userAnswerIndex = widget.userAnswers.length > index ? widget.userAnswers[index] : -1;
              final correctIndex = question.correctAnswerIndex;
              final bool isCorrect = userAnswerIndex == correctIndex;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Soru ${index + 1}: ${question.text}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (userAnswerIndex != -1)
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              const TextSpan(text: 'Senin Cevabın: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: question.options[userAnswerIndex].text,
                                style: TextStyle(color: isCorrect ? Colors.green[800] : Colors.red[800], fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (!isCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'Doğru Cevap: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: question.options[correctIndex].text,
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
