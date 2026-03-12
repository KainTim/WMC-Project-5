import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeOption { lightBlue, darkPurple, lightMint, darkAmber, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_option';
  AppThemeOption _selectedTheme = AppThemeOption.system;

  AppThemeOption get selectedTheme => _selectedTheme;

  ThemeMode get themeMode {
    switch (_selectedTheme) {
      case AppThemeOption.lightBlue:
      case AppThemeOption.lightMint:
        return ThemeMode.light;
      case AppThemeOption.darkPurple:
      case AppThemeOption.darkAmber:
        return ThemeMode.dark;
      case AppThemeOption.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    switch (_selectedTheme) {
      case AppThemeOption.lightMint:
        return _mintLightTheme;
      case AppThemeOption.lightBlue:
      case AppThemeOption.darkPurple:
      case AppThemeOption.darkAmber:
      case AppThemeOption.system:
        return _blueLightTheme;
    }
  }

  ThemeData get darkTheme {
    switch (_selectedTheme) {
      case AppThemeOption.darkAmber:
        return _amberDarkTheme;
      case AppThemeOption.lightBlue:
      case AppThemeOption.darkPurple:
      case AppThemeOption.lightMint:
      case AppThemeOption.system:
        return _purpleDarkTheme;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'system';
    _selectedTheme = _themeFromString(themeName);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeOption option) async {
    _selectedTheme = option;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeToString(option));
  }

  String _themeToString(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.lightBlue:
        return 'light_blue';
      case AppThemeOption.darkPurple:
        return 'dark_purple';
      case AppThemeOption.lightMint:
        return 'light_mint';
      case AppThemeOption.darkAmber:
        return 'dark_amber';
      case AppThemeOption.system:
        return 'system';
    }
  }

  AppThemeOption _themeFromString(String theme) {
    switch (theme) {
      case 'light':
      case 'light_blue':
        return AppThemeOption.lightBlue;
      case 'dark':
      case 'dark_purple':
        return AppThemeOption.darkPurple;
      case 'light_mint':
        return AppThemeOption.lightMint;
      case 'dark_amber':
        return AppThemeOption.darkAmber;
      case 'system':
      default:
        return AppThemeOption.system;
    }
  }

  ThemeData get _blueLightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }

  ThemeData get _purpleDarkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
    );
  }

  ThemeData get _mintLightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00897B),
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
      ),
    );
  }

  ThemeData get _amberDarkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8F00),
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    );
  }
}
