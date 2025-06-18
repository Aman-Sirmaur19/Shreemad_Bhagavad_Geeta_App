import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _fontSizeKey = 'fontSize';

  double _fontSize = 17;

  double get fontSize => _fontSize;

  FontSizeProvider() {
    _loadFontSize();
  }

  void _loadFontSize() {
    final box = Hive.box(_boxName);
    _fontSize = box.get(_fontSizeKey, defaultValue: 17.0);
  }

  void setFontSize(double value) {
    _fontSize = value;
    Hive.box(_boxName).put(_fontSizeKey, value);
    notifyListeners();
  }
}
