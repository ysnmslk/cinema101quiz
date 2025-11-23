import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.amber,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Cin101',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quiz Uygulaması',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: currentIndex == 0 ? Colors.black : Colors.black87,
            ),
            title: Text(
              'Ana Sayfa',
              style: TextStyle(
                color: currentIndex == 0 ? Colors.black : Colors.black87,
                fontWeight: currentIndex == 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: currentIndex == 0,
            selectedTileColor: Colors.amber.shade300,
            onTap: () {
              if (currentIndex != 0) {
                context.go('/');
              }
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              color: currentIndex == 1 ? Colors.black : Colors.black87,
            ),
            title: Text(
              'Profil',
              style: TextStyle(
                color: currentIndex == 1 ? Colors.black : Colors.black87,
                fontWeight: currentIndex == 1 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: currentIndex == 1,
            selectedTileColor: Colors.amber.shade300,
            onTap: () {
              if (currentIndex != 1) {
                context.go('/profile');
              }
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: currentIndex == 2 ? Colors.black : Colors.black87,
            ),
            title: Text(
              'Ayarlar',
              style: TextStyle(
                color: currentIndex == 2 ? Colors.black : Colors.black87,
                fontWeight: currentIndex == 2 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: currentIndex == 2,
            selectedTileColor: Colors.amber.shade300,
            onTap: () {
              if (currentIndex != 2) {
                context.go('/settings');
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

