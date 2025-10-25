
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/login/providers/auth_provider.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:myapp/quiz/models/quiz_result_model.dart';
import 'package:myapp/quiz/services/firestore_service.dart';
import 'package:provider/provider.dart';

// 1. Widget'ı StatefulWidget'a dönüştür
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

// 2. State sınıfını oluştur
class _QuizResultsState extends State<QuizResults> {
  
  // 3. initState içinde kaydetme işlemini tetikle
  @override
  void initState() {
    super.initState();
    // initState, build'den önce sadece bir kez çalışır.
    // Bu, sonucu veritabanına bir kez kaydetmek için mükemmel bir yerdir.
    // Kullanıcı bilgisine erişmek için context'i kullanmadan, bir sonraki frame'de çalışmasını sağlıyoruz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResult();
    });
  }

  // 4. Sonucu kaydeden özel metot
  Future<void> _saveResult() async {
    // Servislere ve provider'lara eriş
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final firestoreService = FirestoreService();

    final user = authProvider.user;
    if (user == null) return; // Eğer kullanıcı giriş yapmamışsa kaydetme

    // Kaydedilecek QuizResult nesnesini oluştur
    final newResult = QuizResult(
      id: '', // Firestore otomatik ID atayacak
      userId: user.uid,
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      quizImageUrl: widget.quiz.imageUrl,
      score: widget.score,
      totalQuestions: widget.quiz.questions.length,
      timestamp: Timestamp.now(),
    );

    // Servis aracılığıyla veritabanına kaydet
    try {
      await firestoreService.saveQuizResult(newResult);
      // İsteğe bağlı: Başarılı kayıttan sonra bir mesaj gösterebiliriz
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Sonucunuz başarıyla kaydedildi!')),
      // );
    } catch (e) {
      // İsteğe bağlı: Hata durumunda kullanıcıyı bilgilendir
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
