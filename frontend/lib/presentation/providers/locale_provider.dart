import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'locale';
  Locale? _locale;

  LocaleProvider() {
    _loadLocale(); // Завантажуємо мову при старті
  }

  Locale? get locale => _locale;

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_localeKey);
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
    // Якщо null, _locale залишиться null, і додаток використає мову системи
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    
    notifyListeners(); // Повідомляємо всім віджетам, що треба перебудуватися
  }

  void clearLocale() async {
    _locale = null; // Скидаємо до мови системи
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
    notifyListeners();
  }
}