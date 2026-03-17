import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tele_kiosk/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeNotifier', () {
    test('initializes with correct mode', () {
      final notifier = ThemeNotifier(ThemeMode.dark);
      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('toggleMode changes mode and saves preference', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = ThemeNotifier(ThemeMode.light);
      await notifier.toggleMode();
      expect(notifier.themeMode, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('darkTheme'), true);
    });

    test('toggleMode returns true on success', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = ThemeNotifier(ThemeMode.light);
      final result = await notifier.toggleMode();
      expect(result, true);
    });
  });
}