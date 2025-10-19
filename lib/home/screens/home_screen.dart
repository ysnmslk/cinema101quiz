
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/login/providers/auth_provider.dart'; // Doğru import

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HATA DÜZELTİLDİ: AppAuthProvider kullanılıyor
    final authProvider = Provider.of<AppAuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        // EKSTRA: Çıkış yapma butonu eklendi
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // authProvider üzerinden çıkış yapma fonksiyonu çağrılıyor
              authProvider.signOut();
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hoş Geldiniz!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            // EKSTRA: Giriş yapan kullanıcı bilgileri gösteriliyor
            if (user != null) ...[
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL ?? ''),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text('${user.displayName}'),
              const SizedBox(height: 5),
              Text('${user.email}'),
            ] else ...[
              const Text('Kullanıcı bilgileri yüklenemedi.'),
            ]
          ],
        ),
      ),
    );
  }
}
