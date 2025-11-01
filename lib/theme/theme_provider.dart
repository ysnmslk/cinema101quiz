
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
      return 'Sistem';
    }
  }

  // TÜR DÜZELTİLDİ: Color -> MaterialAccentColor
  static const MaterialAccentColor _primarySeedColor = Colors.blueAccent;

  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
    bodyMedium: GoogleFonts.openSans(fontSize: 14),
    labelLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
  );

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primarySeedColor,
          brightness: Brightness.light,
        ),
        textTheme: _appTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: _primarySeedColor,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: _primarySeedColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primarySeedColor,
          brightness: Brightness.dark,
        ),
        textTheme: _appTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: _primarySeedColor.shade200, // Artık bu satır geçerli
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
}
