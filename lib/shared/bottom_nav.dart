
import 'package:flutter/material.dart';
import 'package:myapp/settings/screens/settings_screen.dart'; // Ayarlar ekranını import et

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
            // Ana sayfaya git (eğer zaten orada değilsek)
            if (ModalRoute.of(context)?.settings.name != '/') {
               // Ana ekran yığının en altında olmalı, bu yüzden pushReplacementNamed daha uygun
               // Ancak basitlik için şimdilik Navigator.popUntil kullanabiliriz veya doğrudan ana sayfaya dönebiliriz.
               // Şimdilik varsayılan davranışı koruyalım.
               Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } 
            break;
          case 1:
            // Profil sayfasına git (henüz oluşturulmadı)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil sayfası henüz hazır değil.')),
            );
            break;
            
          // --- DEĞİŞİKLİĞİN YAPILDIĞI YER ---
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
      showUnselectedLabels: true, // Tüm etiketleri göster
    );
  }
}
