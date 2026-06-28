import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  Color _currentSeedColor = AppTheme.primaryColor;
  bool _isDarkMode = false;

  ThemeData get currentTheme => AppTheme.buildTheme(_currentSeedColor, isDark: _isDarkMode);

  void updateSeedColor(Color newColor) {
    _currentSeedColor = newColor;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}