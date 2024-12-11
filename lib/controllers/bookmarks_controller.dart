import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../services/api_service.dart';

class BookmarksController extends GetxController {
  var chapters = <dynamic>[].obs;
  var bookmarkedChapters = <String>[].obs;

  var verses = <String, dynamic>{}.obs;
  var bookmarkedVerses = <String, Map<dynamic, dynamic>>{}.obs;

  // @override
  // void onInit() {
  //   super.onInit();
  //   _fetchAndSetChapters();
  // }

  void _fetchAndSetChapters() async {
    final fetchedChapters = await ApiService().fetchChapters();
    chapters.value = fetchedChapters;
  }

  void setChapters(List<dynamic> allChapters) {
    chapters.value = allChapters;
  }

  void loadChaptersBookmark() {
    final box = Hive.box<String>('summaryBookmarks');
    bookmarkedChapters.assignAll(box.values.toList());
  }

  void loadVersesBookmark() {
    final box = Hive.box<Map<dynamic, dynamic>>('verseBookmarks');
    final Map<String, Map<dynamic, dynamic>> temp = {};
    for (var key in box.keys) {
      temp[key] = box.get(key, defaultValue: {})!;
    }
    bookmarkedVerses.assignAll(temp);
  }
}
