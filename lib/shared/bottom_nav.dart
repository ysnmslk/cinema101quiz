
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex; // Hangi sayfanın aktif olduğunu belirtmek için

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Aktif indeksi ayarla
      onTap: (index) {
        // Henüz diğer sayfalar olmadığı için sadece sayfa geçişlerini simüle ediyoruz
        switch (index) {
          case 0:
            // Zaten ana sayfadayız, bir şey yapma veya sayfayı yenile
            if (ModalRoute.of(context)!.settings.name != '/home') {
              Navigator.pushReplacementNamed(context, '/home');
            }
            break;
          case 1:
            // Profil sayfasına git (henüz oluşturulmadı)
            // Navigator.pushReplacementNamed(context, '/profile');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profil sayfası henüz hazır değil.')),
            );
            break;
          case 2:
            // Ayarlar sayfasına git (henüz oluşturulmadı)
            // Navigator.pushReplacementNamed(context, '/settings');
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ayarlar sayfası henüz hazır değil.')),
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
      // Seçili ve seçili olmayan ikonların renklerini belirleyebilirsiniz
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
    );
  }
}
