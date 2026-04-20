import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  Color _currentSeedColor = AppTheme.primaryColor;
  bool _isDarkMode = false;

  ThemeData get currentTheme => AppTheme.buildTheme(_currentSeedColor, isDark: _isDarkMode);

  // Метод для динамической смены цвета
  void updateSeedColor(Color newColor) {
    _currentSeedColor = newColor;
    notifyListeners();
  }

  // Метод для переключения темной темы
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}