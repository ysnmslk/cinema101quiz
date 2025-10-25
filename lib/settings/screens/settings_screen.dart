
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // ThemeProvider'ı dinleyerek UI'ı güncel tutarız
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Görünüm',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Divider(),
                // Aydınlık Tema Seçeneği
                RadioListTile<ThemeMode>(
                  title: const Text('Aydınlık Mod'),
                  subtitle: const Text('Uygulamayı her zaman aydınlık temada kullanın.'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
                // Karanlık Tema Seçeneği
                RadioListTile<ThemeMode>(
                  title: const Text('Karanlık Mod'),
                  subtitle: const Text('Uygulamayı her zaman karanlık temada kullanın.'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
                // Sistem Varsayılanı Seçeneği
                RadioListTile<ThemeMode>(
                  title: const Text('Sistem Varsayılanı'),
                  subtitle: const Text('Cihazınızın mevcut temasına uyum sağla.'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
