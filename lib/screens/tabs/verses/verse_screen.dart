import 'dart:convert';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../services/api_service.dart';
import '../../../services/translation_service.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../../widgets/custom_banner_ad.dart';
import '../../../widgets/internet_connectivity_button.dart';

class VerseScreen extends StatefulWidget {
  final String chapterNumber;
  final String verseNumber;

  const VerseScreen({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
  });

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> verse;
  String selectedLanguage = 'hi';
  String selectedLanguageName = 'Hindi';

  void _toggleBookmark(String chapterNumber, String verseNumber) {
    var box = Hive.box<Map>('verseBookmarks');
    var bookmarks = box.get(chapterNumber);

    if (bookmarks == null) {
      bookmarks = SplayTreeMap<String, String>();
    } else {
      bookmarks = SplayTreeMap<String, String>.from(bookmarks);
    }

    if (bookmarks.containsKey(verseNumber)) {
      bookmarks.remove(verseNumber);
      if (bookmarks.isEmpty) {
        box.delete(chapterNumber);
      } else {
        box.put(chapterNumber, bookmarks);
      }
    } else {
      bookmarks[verseNumber] = verseNumber;
      box.put(chapterNumber, bookmarks);
    }
  }

  bool _isBookmarked(String chapterNumber, String verseNumber) {
    var box = Hive.box<Map>('verseBookmarks');
    var bookmarks = box.get(chapterNumber, defaultValue: {});
    return bookmarks!.containsKey(verseNumber);
  }

  @override
  void initState() {
    super.initState();
    verse = apiService.fetchParticularVerse(
      widget.chapterNumber,
      widget.verseNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
    selectedLanguage = languageProvider.selectedLanguage;
    selectedLanguageName = languageProvider.selectedLanguageName;
    return DefaultTabController(
      length: selectedLanguageName == 'Hindi' ? 1 : 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: Text('Verse ${widget.verseNumber}'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() =>
                    _toggleBookmark(widget.chapterNumber, widget.verseNumber));
                bookmarksProvider.loadVersesBookmark();
              },
              tooltip: 'Bookmark',
              icon: Icon(
                _isBookmarked(widget.chapterNumber, widget.verseNumber)
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: FutureBuilder<Map<String, dynamic>>(
          future: verse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return InternetConnectivityButton(
                  onPressed: () => setState(() {
                        verse = apiService.fetchParticularVerse(
                          widget.chapterNumber,
                          widget.verseNumber,
                        );
                      }));
            } else {
              final item = snapshot.data!;
              final hindiTranslation =
                  (item['translations'] as List).firstWhere(
                (t) => t['author_name'] == 'Swami Tejomayananda',
                orElse: () => null,
              );
              final hindiTranslationText = utf8
                  .decode(hindiTranslation['description'].runes.toList())
                  .trim();
              final englishTranslation =
                  (item['translations'] as List).firstWhere(
                (t) => t['author_name'] == 'Shri Purohit Swami',
                orElse: () => null,
              );
              final englishTranslationText = utf8
                  .decode(englishTranslation['description'].runes.toList())
                  .trim();
              final hindiCommentary = (item['commentaries'] as List).firstWhere(
                (t) => t['author_name'] == 'Swami Chinmayananda',
                orElse: () => null,
              );
              final hindiCommentaryText = utf8
                  .decode(hindiCommentary['description'].runes.toList())
                  .trim();
              return FutureBuilder(
                  future: TranslationService.translate(
                      hindiCommentaryText, selectedLanguage),
                  builder: (context, translationSnapshot) {
                    if (translationSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (translationSnapshot.hasError) {
                      return const Center(
                          child: Text("Error translating text"));
                    }
                    final translatedDescription = selectedLanguage == 'hi'
                        ? hindiCommentaryText
                        : translationSnapshot.data;
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            utf8.decode(item['text'].runes.toList()).trim(),
                            style: TextStyle(
                              height: 0.9,
                              fontSize: 18,
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const Text('Translation:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 5),
                          Text(
                            '$hindiTranslationText\n\n$englishTranslationText',
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const Text('Description:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              )),
                          TabBar(
                            dividerHeight: .3,
                            dividerColor: Colors.transparent,
                            labelColor: Colors.brown,
                            indicatorColor: Colors.brown,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: [
                              const Tab(text: 'Hindi'),
                              if (selectedLanguageName != 'Hindi')
                                Tab(text: selectedLanguageName),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Text(
                                    hindiCommentaryText,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (selectedLanguageName != 'English')
                                  SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      translatedDescription ??
                                          hindiCommentaryText,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
