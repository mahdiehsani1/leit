// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en'); // پیش‌فرض انگلیسی

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isPersian => _locale.languageCode == 'fa';

  ThemeController() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // لود تم
    final themeString = prefs.getString('theme') ?? 'system';
    if (themeString == 'light')
      _themeMode = ThemeMode.light;
    else if (themeString == 'dark')
      _themeMode = ThemeMode.dark;
    else
      _themeMode = ThemeMode.system;

    // لود زبان
    final langCode = prefs.getString('language_code') ?? 'en';
    _locale = Locale(langCode);

    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    if (theme == 'light')
      _themeMode = ThemeMode.light;
    else if (theme == 'dark')
      _themeMode = ThemeMode.dark;
    else
      _themeMode = ThemeMode.system;

    await prefs.setString('theme', theme);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(code);
    await prefs.setString('language_code', code);
    notifyListeners();
  }
}
