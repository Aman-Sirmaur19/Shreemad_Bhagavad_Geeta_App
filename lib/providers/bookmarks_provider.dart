import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BookmarksProvider extends ChangeNotifier {
  List<dynamic> _chapters = [];
  List<String> _bookmarkedChapters = [];
  Map<String, Map<dynamic, dynamic>> _bookmarkedVerses = {};

  List<dynamic> get chapters => _chapters;

  List<String> get bookmarkedChapters => _bookmarkedChapters;

  Map<String, Map<dynamic, dynamic>> get bookmarkedVerses => _bookmarkedVerses;

  void setChapters(List<dynamic> allChapters) {
    _chapters = allChapters;
    notifyListeners();
  }

  Future<void> loadChaptersBookmark() async {
    final box = Hive.box<String>('summaryBookmarks');
    _bookmarkedChapters = box.values.toList();
    notifyListeners();
  }

  Future<void> loadVersesBookmark() async {
    final box = Hive.box<Map<dynamic, dynamic>>('verseBookmarks');
    final Map<String, Map<dynamic, dynamic>> temp = {};
    for (var key in box.keys) {
      temp[key] = box.get(key, defaultValue: {})!;
    }
    _bookmarkedVerses = temp;
    notifyListeners();
  }
}
