
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("Kullanıcı Adı"), // İleride burası dinamik olacak
            accountEmail: Text("kullanici@email.com"), // İleride burası dinamik olacak
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50),
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Çıkış Yap'),
            onTap: () {
              // TODO: Çıkış yapma işlevi eklenecek
              Navigator.pop(context); // Menüyü kapat
            },
          ),
        ],
      ),
    );
  }
}
