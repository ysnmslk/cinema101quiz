
import 'package:flutter/material.dart';
import 'package:myapp/shared/bottom_nav.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('Profil Ekranı'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
