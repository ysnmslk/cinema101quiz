
import 'package:flutter/material.dart';
import 'package:myapp/profile/screens/profile_screen.dart'; // Profil ekranını import et
import 'package:myapp/settings/screens/settings_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        // Eğer zaten o sekmedeysek bir şey yapma
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            // Ana sayfaya git
            if (ModalRoute.of(context)?.settings.name != '/') {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            }
            break;
            
          // --- DEĞİŞİKLİĞİN YAPILDIĞI YER ---
          case 1:
            // Profil sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;

          case 2:
            // Ayarlar sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, 
    );
  }
}
