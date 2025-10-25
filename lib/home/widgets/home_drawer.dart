
import 'package:flutter/material.dart';
import 'package:myapp/admin/screens/add_quiz_screen.dart';
import 'package:myapp/login/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
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
    // Tema ayarları artık özel bir ekranda yönetildiği için burada ThemeProvider'a gerek kalmadı.

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
              
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddQuizScreen()),
              );

              if (result == true) {
                widget.onQuizAdded();
              }
            },
          ),
          const Divider(),
          // --- HATA DÜZELTİLDİ ---
          // Tema değiştirme Switch'i kaldırıldı çünkü bu işlevsellik artık 
          // BottomNavBar'daki Ayarlar ekranından yönetiliyor.
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final navigator = Navigator.of(context);
              await authProvider.signOut();
              if (!mounted) return; 
              // Çıkış yaptıktan sonra menüyü güvenle kapat
              navigator.pop();
            },
          ),
        ],
      ),
    );
  }
}
