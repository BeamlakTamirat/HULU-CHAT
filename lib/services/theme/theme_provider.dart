import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme mode key for shared preferences
  static const String _themeKey = 'dark_mode';

  // Default to light mode
  bool _isDarkMode = false;

  // Getter for current theme state
  bool get isDarkMode => _isDarkMode;

  // Constructor - initialize with saved preference
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  // Save theme preference
  Future<void> _saveThemePreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  // Toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Set specific theme mode
  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _saveThemePreference();
      notifyListeners();
    }
  }

  // Get theme data based on current mode
  ThemeData getTheme() {
    if (_isDarkMode) {
      return _getDarkTheme();
    } else {
      return _getLightTheme();
    }
  }

  // Dark theme data
  ThemeData _getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF1A237E),
      scaffoldBackgroundColor: Color(0xFF0A1929),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF2196F3),
        secondary: Color(0xFF64B5F6),
        surface: Color(0xFF102A43),
        onSurface: Color(0xFFBBDEFB),
      ),
      cardColor: Color(0xFF102A43),
      canvasColor: Color(0xFF0A1929),
      dividerColor: Color(0xFF1E88E5).withOpacity(0.2), dialogTheme: DialogThemeData(backgroundColor: Color(0xFF102A43)),
    );
  }

  // Light theme data
  ThemeData _getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF1565C0),
      scaffoldBackgroundColor: Color(0xFFBBDEFB),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1565C0),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2196F3),
          foregroundColor: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2196F3),
        secondary: Color(0xFF90CAF9),
        surface: Colors.white,
      ),
    );
  }
}
