import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  LanguageProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _appLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  void changeLanguage(Locale type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) return;

    _appLocale = type;
    await prefs.setString('language_code', type.languageCode);
    notifyListeners();
  }
}
