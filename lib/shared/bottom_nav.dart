
import 'package:flutter/material.dart';
import 'package:myapp/home/screens/home_screen.dart';
import 'package:myapp/profile/screens/profile_screen.dart';
import 'package:myapp/settings/screens/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Eğer zaten o sayfadaysak tekrar yönlendirme yapma
        if (index == currentIndex) return;

        switch (index) {
          case 0: // Ana Sayfa
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const HomeScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 1: // Profil
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const ProfileScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
          case 2: // Ayarlar
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const SettingsScreen(),
                transitionDuration: Duration.zero,
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ayarlar',
        ),
      ],
    );
  }
}
