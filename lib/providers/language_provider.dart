import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageProvider extends ChangeNotifier {
  final _box = Hive.box('languageBox');
  String _selectedLanguage = 'hi';
  String _selectedLanguageName = 'Hindi';

  LanguageProvider() {
    _selectedLanguage = _box.get('selectedLanguage', defaultValue: 'hi');
    _selectedLanguageName =
        _box.get('selectedLanguageName', defaultValue: 'Hindi');
  }

  String get selectedLanguage => _selectedLanguage;

  String get selectedLanguageName => _selectedLanguageName;

  void setLanguage(String languageCode, String languageName) {
    _selectedLanguage = languageCode;
    _selectedLanguageName = languageName;
    _box.put('selectedLanguage', languageCode);
    _box.put('selectedLanguageName', languageName);
    notifyListeners();
  }
}
