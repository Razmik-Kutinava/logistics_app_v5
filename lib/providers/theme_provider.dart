import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode =
      ThemeMode.dark; // По умолчанию темная тема для водителей

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// Загружает сохраненный режим темы
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);

      if (themeModeString != null) {
        switch (themeModeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          default:
            _themeMode = ThemeMode.dark; // Темная тема по умолчанию
        }
      }
      notifyListeners();
    } catch (e) {
      // Если произошла ошибка, используем темную тему по умолчанию
      _themeMode = ThemeMode.dark;
    }
  }

  /// Сохраняет режим темы
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeModeString;

      switch (_themeMode) {
        case ThemeMode.light:
          themeModeString = 'light';
          break;
        case ThemeMode.dark:
          themeModeString = 'dark';
          break;
        case ThemeMode.system:
          themeModeString = 'system';
          break;
      }

      await prefs.setString(_themeKey, themeModeString);
    } catch (e) {
      // Игнорируем ошибки сохранения
      debugPrint('Ошибка сохранения темы: $e');
    }
  }

  /// Переключает между светлой и темной темой
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
    await _saveThemeMode();
  }

  /// Устанавливает конкретный режим темы
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveThemeMode();
    }
  }

  /// Устанавливает светлую тему
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Устанавливает темную тему
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Устанавливает системную тему
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
