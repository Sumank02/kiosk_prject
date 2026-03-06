import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _mode;
  ThemeNotifier(this._mode);

  ThemeMode get themeMode => _mode;

  Future<bool> toggleMode() async {
    try {
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkTheme', _mode == ThemeMode.dark);
      notifyListeners();
      return true;
    } catch (e) {
      // If save fails, revert the mode change
      _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      print('Theme toggle save failed: $e');
      return false;
    }
  }
}

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

