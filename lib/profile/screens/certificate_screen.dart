
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/quiz/models/quiz_result_model.dart';
import 'package:intl/intl.dart';

class CertificateScreen extends StatelessWidget {
  final QuizResult result;

  const CertificateScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd MMMM yyyy');
    final double percentage = (result.score / result.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Başarı Sertifikası'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // İçeriğe göre boyutlandır
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, size: 60, color: Colors.yellow[700]),
                  const SizedBox(height: 16),
                  Text(
                    'TEBRİKLER!',
                    style: GoogleFonts.oswald(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bu sertifika, sizin',
                    style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.quizTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'quizini başarıyla tamamladığınızı doğrular.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Divider(color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Skor', '${result.score}/${result.totalQuestions}', context, Colors.white),
                      _buildStatColumn('Başarı', '${percentage.toStringAsFixed(0)}%', context, Colors.white),
                    ],
                  ),
                  const SizedBox(height: 24),
                   Text(
                    'Tamamlanma Tarihi: ${formatter.format(result.timestamp.toDate())}',
                    style: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white,
                       foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Geri Dön'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, BuildContext context, Color color) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.oswald(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
