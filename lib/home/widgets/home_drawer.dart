
import 'package:flutter/material.dart';
import 'package:myapp/admin/screens/add_quiz_screen.dart';

import 'package:myapp/login/providers/auth_provider.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  // HomeScreen'deki listeyi yenilemek için bir callback fonksiyonu
  final VoidCallback onQuizAdded;

  const HomeDrawer({super.key, required this.onQuizAdded});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.user;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'Misafir'),
            accountEmail: Text(user?.email ?? 'Giriş yapılmadı'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null ? const Icon(Icons.person, size: 50) : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('Quizler'),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Yeni Quiz Ekle'),
            onTap: () async {
              Navigator.pop(context); // Önce menüyü kapat
              
              // AddQuizScreen'e git ve sonucunu bekle
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddQuizScreen()),
              );

              // Eğer sonuç true ise (yani quiz eklendi ise), callback'i çalıştır
              if (result == true) {
                widget.onQuizAdded();
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Karanlık Mod"),
            secondary: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await authProvider.signOut();
              if (!mounted) return; 
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
