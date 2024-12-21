import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../secrets.dart';
import '../../providers/bookmarks_provider.dart';

class SummaryScreen extends StatefulWidget {
  final dynamic chapter;

  const SummaryScreen({super.key, required this.chapter});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
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
    _initializeBannerAd();
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
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
      body: ListView(
        padding: const EdgeInsets.all(10),
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
          const SizedBox(height: 5),
          Text(
            widget.chapter['chapter_summary'],
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
