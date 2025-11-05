
import 'package:flutter/material.dart';
import 'package:myapp/profile/services/firestore_service.dart';
import 'package:myapp/quiz/models/quiz_model.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';


class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz, required String quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questionsFuture;
  int _currentQuestionIndex = 0;
  int _score = 0;
  late List<int?> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  // DÜZELTME: Sorular doğrudan quiz nesnesinden alınıyor.
  Future<List<Question>> _loadQuestions() async {
    // Firestore'a tekrar gitmek yerine widget'tan gelen soruları kullan
    final questions = List<Question>.from(widget.quiz.questions);
    
    // Cevaplar için bir liste oluştur
    _selectedAnswers = List.generate(questions.length, (_) => null);
    
    // Soruları karıştır
    questions.shuffle();
    
    // Gelecekteki bir değer olarak döndür
    return Future.value(questions);
  }

  void _answerQuestion(int selectedOptionIndex, List<Question> questions) {
    if (_selectedAnswers[_currentQuestionIndex] == null) {
      final question = questions[_currentQuestionIndex];
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = selectedOptionIndex;
        if (question.options[selectedOptionIndex].isCorrect) {
          _score++;
        }
      });

      // Kısa bir gecikmeden sonra otomatik olarak sonraki soruya geç
      Future.delayed(const Duration(milliseconds: 800), () {
        _nextQuestion(questions.length);
      });
    }
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResults(totalQuestions);
    }
  }

  void _showResults(int totalQuestions) async {
    final userId = context.read<AuthService>().currentUser?.uid ?? '';

    if (userId.isNotEmpty) {
      await context.read<FirestoreService>().saveUserResult(
            userId,
            widget.quiz.id,
            _score,
            totalQuestions, // Düzeltme: `widget.quiz.questions!.length` yerine `totalQuestions`
          );
    }
    
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          quiz: widget.quiz,
          score: _score,
          totalQuestions: totalQuestions, // Düzeltme: `totalQuestions` gönderiliyor
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(snapshot.hasError ? 'Hata: ${snapshot.error}' : 'Bu quiz için soru bulunamadı.'));
          }

          final questions = snapshot.data!;
          return _buildQuizBody(questions);
        },
      ),
    );
  }

  Widget _buildQuizBody(List<Question> questions) {
    // Eğer index sınır dışındaysa, sonuç ekranını göster
    if (_currentQuestionIndex >= questions.length) {
      // Bu durumun yaşanmaması gerekir, ama bir güvenlik önlemi.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResults(questions.length);
      });
      return const Center(child: CircularProgressIndicator());
    }

    final question = questions[_currentQuestionIndex];
    final bool isAnswered = _selectedAnswers[_currentQuestionIndex] != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / questions.length,
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Soru ${_currentQuestionIndex + 1} / ${questions.length}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            question.text,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                Color? tileColor;
                Icon? trailingIcon;

                if (isAnswered) {
                  if (option.isCorrect) {
                    tileColor = Colors.green.withAlpha(75);
                    trailingIcon = const Icon(Icons.check, color: Colors.green);
                  } else if (isSelected) {
                    tileColor = Colors.red.withAlpha(75);
                    trailingIcon = const Icon(Icons.close, color: Colors.red);
                  }
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? (option.isCorrect ? Colors.green : Colors.red) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  color: tileColor,
                  child: ListTile(
                    title: Text(option.text, style: Theme.of(context).textTheme.titleMedium),
                    onTap: isAnswered ? null : () => _answerQuestion(index, questions),
                    trailing: trailingIcon,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Sonuç ekranını da düzelt
class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${quiz.title} Sonuçları'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tebrikler!', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text(
                "Quiz'i tamamladın.",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Skorun: $score / $totalQuestions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Başarı: ${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfaya Dön'),
                onPressed: () {
                  // Düzeltme: Ana ekrana (MainScreen) dönmek için `pushAndRemoveUntil` kullan
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
