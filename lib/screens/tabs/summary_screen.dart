import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_banner_ad.dart';
import '../../widgets/font_size_slider.dart';
import '../../services/translation_service.dart';
import '../../providers/language_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/font_size_provider.dart';

class SummaryScreen extends StatefulWidget {
  final dynamic chapter;

  const SummaryScreen({super.key, required this.chapter});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  String _selectedLanguageName = 'English';
  late TabController _tabController;

  /// Cache the translation future so it does not reload on every setState
  late Future<String?> _translationFuture;

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
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 1,
      vsync: this,
    );
    // initialize with default chapter summary (English)
    _translationFuture = Future.value(widget.chapter['chapter_summary']);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageProvider = Provider.of<LanguageProvider>(context);
    final newLang = languageProvider.selectedLanguage;
    final newLangName = languageProvider.selectedLanguageName;
    if (newLang != _selectedLanguage) {
      _selectedLanguage = newLang;
      _selectedLanguageName = newLangName;
      // update translation future
      if (_selectedLanguage == 'en') {
        _translationFuture = Future.value(widget.chapter['chapter_summary']);
      } else {
        _translationFuture = TranslationService.translate(
          widget.chapter['chapter_summary'],
          _selectedLanguage,
        );
      }
      // update tab count
      final tabCount = (_selectedLanguageName == 'English') ? 1 : 2;
      _tabController.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
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
              setState(() =>
                  _toggleBookmark(widget.chapter['chapter_number'].toString()));
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
      body: FutureBuilder<String?>(
        future: _translationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error translating text"));
          }

          final original = widget.chapter['chapter_summary'] as String;
          final translated = snapshot.data ?? original;
          final isOnlyEnglish = _selectedLanguageName == 'English';

          // build tab views with dynamic font size
          final tabViews = <Widget>[
            SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Text(
                original,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ];
          if (!isOnlyEnglish) {
            tabViews.add(
              SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Text(
                  translated,
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
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                              ),
                            ),
                          ],
                        ),
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
                      const Tab(text: 'English'),
                      if (!isOnlyEnglish) Tab(text: _selectedLanguageName),
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
