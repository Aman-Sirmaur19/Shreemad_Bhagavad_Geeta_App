import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_banner_ad.dart';
import '../../services/translation_service.dart';
import '../../providers/language_provider.dart';
import '../../providers/bookmarks_provider.dart';

class SummaryScreen extends StatefulWidget {
  final dynamic chapter;

  const SummaryScreen({super.key, required this.chapter});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String selectedLanguage = 'en';
  String selectedLanguageName = 'English';

  void _toggleBookmark(String chapterNumber) {
    var box = Hive.box<String>('summaryBookmarks');
    if (box.containsKey(chapterNumber)) {
      box.delete(chapterNumber);
    } else {
      box.put(chapterNumber, chapterNumber);
    }
  }

  bool _isBookmarked(String chapterNumber) {
    var box = Hive.box<String>('summaryBookmarks');
    return box.containsKey(chapterNumber);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context);
    selectedLanguage = languageProvider.selectedLanguage;
    selectedLanguageName = languageProvider.selectedLanguageName;
    return DefaultTabController(
      length: selectedLanguageName == 'English' ? 1 : 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: Text('Chapter ${widget.chapter['chapter_number']}'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() => _toggleBookmark(
                    widget.chapter['chapter_number'].toString()));
                bookmarksProvider.loadChaptersBookmark();
              },
              tooltip: 'Bookmark',
              icon: Icon(
                _isBookmarked(widget.chapter['chapter_number'].toString())
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBannerAd(),
        body: FutureBuilder(
            future: TranslationService.translate(
                widget.chapter['chapter_summary'], selectedLanguage),
            builder: (context, translationSnapshot) {
              if (translationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (translationSnapshot.hasError) {
                return const Center(child: Text("Error translating text"));
              }
              final translatedSummary = selectedLanguage == 'en'
                  ? widget.chapter['chapter_summary']
                  : translationSnapshot.data;
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      utf8.decode(widget.chapter['name'].runes.toList()),
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.chapter['name_translated'],
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    RichText(
                      text: TextSpan(
                          text: 'Verses: ',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                                text: widget.chapter['verses_count'].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ))
                          ]),
                    ),
                    const Divider(),
                    const Text(
                      'Meaning:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.chapter['name_meaning'],
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Summary:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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
                        const Tab(text: 'English'),
                        if (selectedLanguageName != 'English')
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
                              widget.chapter['chapter_summary'],
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
                                translatedSummary ??
                                    widget.chapter['chapter_summary'],
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
            }),
      ),
    );
  }
}
