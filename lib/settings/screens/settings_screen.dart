
import 'package:flutter/material.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final AuthService authService = AuthService();

    // Tema değiştirme işlemini yöneten fonksiyon
    void changeTheme(ThemeMode value) {
      themeProvider.setThemeMode(value);
      Navigator.of(context).pop(); // Dialog'u kapat
    }

    // DÜZELTME: Scaffold kaldırıldı, sadece içerik döndürülüyor (MainScreen zaten Scaffold sağlıyor)
    return ListView(
      children: [
        ListTile(
          title: const Text('Tema'),
          subtitle: Text(themeProvider.themeModeName),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Tema Seçin'),
                  content: Consumer<ThemeProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildFakeRadioOption(context, 'Açık', ThemeMode.light, provider.themeMode, changeTheme),
                          _buildFakeRadioOption(context, 'Koyu', ThemeMode.dark, provider.themeMode, changeTheme),
                          _buildFakeRadioOption(context, 'Sistem Varsayılanı', ThemeMode.system, provider.themeMode, changeTheme),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Oturumu Kapat', style: TextStyle(color: Colors.red)),
          onTap: () async {
            final bool? shouldLogout = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Oturumu Kapat'),
                  content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('İptal'),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    TextButton(
                      child: const Text('Evet, Çıkış Yap'),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                );
              },
            );

            if (shouldLogout == true) {
              await authService.signOut();
            }
          },
        ),
      ],
    );
  }

  // Linter uyarısını tetiklemeyen, özel yapım radio butonu listesi elemanı
  Widget _buildFakeRadioOption(BuildContext context, String title, ThemeMode value, ThemeMode groupValue, void Function(ThemeMode) onChanged) {
    final bool isSelected = value == groupValue;
    final Color? radioColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).unselectedWidgetColor;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: radioColor,
            ),
            const SizedBox(width: 16),
            Text(title),
          ],
        ),
      ),
    );
  }
}
