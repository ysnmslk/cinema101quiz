
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:myapp/quiz/models/quiz_models.dart';
import 'package:share_plus/share_plus.dart';

class CertificateScreen extends StatefulWidget {
  final QuizResultDetails resultDetails;

  const CertificateScreen({super.key, required this.resultDetails});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR');
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.resultDetails.quiz;
    final result = widget.resultDetails.result;
    final double scorePercentage = result.totalQuestions > 0
        ? (result.score / result.totalQuestions) * 100
        : 0;
    final String formattedDate = DateFormat.yMMMMd('tr_TR').format(result.completedAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifika'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 4),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.grey[200]!, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  // Düzeltme: `withOpacity` yerine `Color.fromRGBO` kullanıldı.
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'BAŞARI SERTİFİKASI',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bu sertifika, aşağıdaki quizi başarıyla tamamlayan kişiye takdim edilmiştir:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                Text(
                  quiz.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                Text(
                  '(${quiz.topic})',
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                Text(
                  'Puan: ${result.score}/${result.totalQuestions} (%${scorePercentage.toStringAsFixed(1)})',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tarih: $formattedDate',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Sen de sinema bilginle arkadaşlarınla yarışmak için Cinema101 quiz uygulamasını indir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    final String shareText = 
                        'Cinema101 Quiz\'te ${quiz.title} quizini tamamladım! '
                        'Puanım: ${result.score}/${result.totalQuestions} (%${scorePercentage.toStringAsFixed(1)})\n\n'
                        'Sen de sinema bilginle arkadaşlarınla yarışmak için Cinema101 quiz uygulamasını indir!';
                    
                    await Share.share(
                      shareText,
                      subject: 'Cinema101 Quiz Başarısı',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Sosyal Medyada Paylaş'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
