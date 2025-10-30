
import 'package:flutter/material.dart';

class AddQuizScreen extends StatelessWidget {
  const AddQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Quiz Ekle'),
      ),
      body: const Center(
        child: Text('Burası yeni quiz ekleme sayfası olacak.'),
      ),
    );
  }
}
