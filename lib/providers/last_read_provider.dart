import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LastReadProvider extends ChangeNotifier {
  final _box = Hive.box('lastReadBox');

  String get lastReadChapter => _box.get('lastReadChapter', defaultValue: '');

  String get lastReadVerse => _box.get('lastReadVerse', defaultValue: '');

  void updateLastRead(String chapter, String verse) {
    _box.put('lastReadChapter', chapter);
    _box.put('lastReadVerse', verse);
    notifyListeners();
  }
}
