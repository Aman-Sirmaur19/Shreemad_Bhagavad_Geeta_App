import 'dart:convert';
import 'dart:developer';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../secrets.dart';
import '../../../services/api_service.dart';
import '../../../providers/bookmarks_provider.dart';
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
  bool isBannerLoaded = false;
  late BannerAd bannerAd;

  void _initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Secrets.bannerAdId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerLoaded = false;
          log(error.message);
        },
      ),
      request: const AdRequest(),
    );
    bannerAd.load();
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
  void initState() {
    super.initState();
    _initializeBannerAd();
    verse = apiService.fetchParticularVerse(
      widget.chapterNumber,
      widget.verseNumber,
    );
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    return Scaffold(
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
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
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
            final hindiTranslation = (item['translations'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Tejomayananda',
              orElse: () => null,
            );
            final englishTranslation =
                (item['translations'] as List).firstWhere(
              (t) => t['author_name'] == 'Shri Purohit Swami',
              orElse: () => null,
            );
            final hindiCommentary = (item['commentaries'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Chinmayananda',
              orElse: () => null,
            );
            final englishCommentary = (item['commentaries'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Sivananda',
              orElse: () => null,
            );
            return ListView(
              padding: const EdgeInsets.all(10),
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
                  '${utf8.decode(hindiTranslation['description'].runes.toList()).trim()}\n\n${utf8.decode(englishTranslation['description'].runes.toList()).trim()}',
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
                const SizedBox(height: 5),
                Text(
                  utf8
                      .decode(hindiCommentary['description'].runes.toList())
                      .trim(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
