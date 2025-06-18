import 'dart:convert';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../../services/api_service.dart';
import '../../../providers/language_provider.dart';
import '../../../providers/bookmarks_provider.dart';
import '../../../providers/font_size_provider.dart';
import '../../../services/translation_service.dart';
import '../../../widgets/custom_banner_ad.dart';
import '../../../widgets/font_size_slider.dart';
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

class _VerseScreenState extends State<VerseScreen>
    with TickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> verse;
  late TabController _tabController;
  late Future<String?> _translationFuture;
  String? _previousLanguage;
  String selectedLanguage = 'hi';
  String selectedLanguageName = 'Hindi';

  @override
  void initState() {
    super.initState();
    verse = apiService.fetchParticularVerse(
      widget.chapterNumber,
      widget.verseNumber,
    );
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageProvider = Provider.of<LanguageProvider>(context);
    selectedLanguage = languageProvider.selectedLanguage;
    selectedLanguageName = languageProvider.selectedLanguageName;

    if (_previousLanguage != selectedLanguage) {
      _previousLanguage = selectedLanguage;

      // Refresh translation only if language changes
      _translationFuture = verse.then((item) {
        final commentaries = item['commentaries'] as List;
        final chinmaya = commentaries.firstWhere(
          (t) => t['author_name'] == 'Swami Chinmayananda',
          orElse: () => null,
        );
        final hindiCommentary = (chinmaya != null &&
                (chinmaya['description'] as String).contains('No commentary'))
            ? commentaries.firstWhere(
                (t) => t['author_name'] == 'Swami Ramsukhdas',
                orElse: () => null,
              )
            : chinmaya;

        final hindiCommentaryText =
            utf8.decode(hindiCommentary['description'].runes.toList()).trim();

        if (selectedLanguage == 'hi') {
          return Future.value(hindiCommentaryText);
        }

        return TranslationService.translate(
            hindiCommentaryText, selectedLanguage);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabControllerIfNeeded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateTabControllerIfNeeded() {
    final newLength = selectedLanguageName == 'Hindi' ? 1 : 2;
    if (_tabController.length != newLength) {
      _tabController.dispose();
      _tabController = TabController(length: newLength, vsync: this);
    }
  }

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
  Widget build(BuildContext context) {
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
    final languageProvider = Provider.of<LanguageProvider>(context);
    selectedLanguage = languageProvider.selectedLanguage;
    selectedLanguageName = languageProvider.selectedLanguageName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTabControllerIfNeeded();
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: Text('Verse ${widget.chapterNumber}.${widget.verseNumber}'),
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
              }),
            );
          } else {
            final item = snapshot.data!;
            final hindiTranslation = (item['translations'] as List).firstWhere(
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

            final commentaries = item['commentaries'] as List;
            final chinmaya = commentaries.firstWhere(
              (t) => t['author_name'] == 'Swami Chinmayananda',
              orElse: () => null,
            );

            final hindiCommentary = (chinmaya != null &&
                    (chinmaya['description'] as String)
                        .contains('No commentary'))
                ? commentaries.firstWhere(
                    (t) => t['author_name'] == 'Swami Ramsukhdas',
                    orElse: () => null,
                  )
                : chinmaya;

            final hindiCommentaryText = utf8
                .decode(hindiCommentary['description'].runes.toList())
                .trim();

            return FutureBuilder(
              future: _translationFuture,
              builder: (context, translationSnapshot) {
                if (translationSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (translationSnapshot.hasError) {
                  return const Center(child: Text("Error translating text"));
                }

                final translatedDescription = selectedLanguage == 'hi'
                    ? hindiCommentaryText
                    : translationSnapshot.data ?? hindiCommentaryText;

                final tabViews = <Widget>[
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      hindiCommentaryText,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ];

                if (selectedLanguageName != 'Hindi') {
                  tabViews.add(
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        translatedDescription,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return NestedScrollView(
                  headerSliverBuilder: (context, _) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                            const Text(
                              'Translation:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
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
                            const Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: FontSizeSlider()),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            const Tab(text: 'Hindi'),
                            if (selectedLanguageName != 'Hindi')
                              Tab(text: selectedLanguageName),
                          ],
                          indicator: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          labelColor: Colors.amber,
                          unselectedLabelColor: Colors.black54,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelPadding: EdgeInsets.zero,
                          indicatorPadding: const EdgeInsets.all(3),
                          dividerColor: Colors.transparent,
                        ),
                        context,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: tabViews,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final BuildContext context;

  _SliverTabBarDelegate(this.tabBar, this.context);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 40,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(this.context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
