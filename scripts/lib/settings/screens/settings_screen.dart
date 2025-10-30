
import 'package:flutter/material.dart';
import 'package:myapp/shared/bottom_nav.dart';
import 'package:myapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';



class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider'a erişim
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        automaticallyImplyLeading: false, // Geri tuşunu gizle
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görünüm Ayarları',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tema Modu'),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistem Teması'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Açık Tema'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Koyu Tema'),
                  ),
                ],
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    // ThemeProvider üzerinden temayı güncelle
                    themeProvider.setThemeMode(newMode);
                  }
                },
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: const BottomNavBar(currentIndex: 2), // index'i 2 olarak ayarla
    );
  }
}
