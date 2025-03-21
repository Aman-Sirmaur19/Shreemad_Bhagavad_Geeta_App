import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../secrets.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/empty_bookmarks.dart';
import '../../providers/bookmarks_provider.dart';
import '../tabs/tab_screen.dart';

class BookmarkedChaptersScreen extends StatefulWidget {
  const BookmarkedChaptersScreen({super.key});

  @override
  State<BookmarkedChaptersScreen> createState() =>
      _BookmarkedChaptersScreenState();
}

class _BookmarkedChaptersScreenState extends State<BookmarkedChaptersScreen> {
  bool isInterstitialLoaded = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    _initializeInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    interstitialAd.dispose();
  }

  void _initializeInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: Secrets.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          setState(() {
            isInterstitialLoaded = true;
          });
          interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _initializeInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              log('Ad failed to show: ${error.message}');
              ad.dispose();
              _initializeInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          log('Failed to load interstitial ad: ${error.message}');
          setState(() {
            isInterstitialLoaded = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    bookmarksProvider.loadChaptersBookmark();
    final bookmarkedSet = bookmarksProvider.bookmarkedChapters.toSet();
    final bookmarked = bookmarksProvider.chapters
        .where((chapter) =>
            bookmarkedSet.contains(chapter['chapter_number'].toString()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Bookmarked Chapters'),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: bookmarked.isEmpty
          ? const EmptyBookmarks(msg: 'No bookmarked chapters')
          : ListView.builder(
              itemCount: bookmarked.length,
              itemBuilder: (context, index) {
                final chapter = bookmarked[index];
                final chapterName = utf8.decode(chapter['name'].runes.toList());
                return Card(
                  color: Colors.brown,
                  child: ListTile(
                    onTap: () {
                      if (isInterstitialLoaded) interstitialAd.show();
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => TabScreen(chapter: chapter)),
                      );
                    },
                    leading: CircleAvatar(
                        child: Text('${chapter['chapter_number']}')),
                    title: Text(
                      chapterName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade400,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['name_translated'],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade200,
                          ),
                        ),
                        Text(
                          'Verses: ${chapter['verses_count']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
