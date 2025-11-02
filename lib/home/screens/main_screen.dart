
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/add_quiz/screens/add_quiz_screen.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/home/screens/home_screen.dart';
import 'package:myapp/profile/screens/profile_screen.dart';
import 'package:myapp/settings/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Sayfa widget'ları
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  // AppBar başlıkları
  static const List<String> _titleOptions = [
    'Quizler',
    'Profilim',
    'Ayarlar',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        // DÜZELTME: Başlık seçili sekmeye göre dinamik olarak değişiyor.
        title: Text(_titleOptions[_selectedIndex]),
        actions: [
          // Sadece profil ve ayarlar ekranında çıkış butonu göster
          if (_selectedIndex >= 1)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authService.signOut(),
              tooltip: 'Oturumu Kapat',
            ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // DÜZELTME: Sadece Ana Sayfa'dayken FloatingActionButton göster.
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddQuizScreen()),
                );
              },
              tooltip: 'Yeni Quiz Ekle',
              child: const Icon(Icons.add),
            )
          : null, // Diğer sayfalarda gösterme
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
