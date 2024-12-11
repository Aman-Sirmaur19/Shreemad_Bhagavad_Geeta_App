import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/bookmarks_controller.dart';
import '../../widgets/empty_bookmarks.dart';
import '../tabs/tab_screen.dart';

class ChaptersBookmarkScreen extends StatefulWidget {
  const ChaptersBookmarkScreen({super.key});

  @override
  State<ChaptersBookmarkScreen> createState() => _ChaptersBookmarkScreenState();
}

class _ChaptersBookmarkScreenState extends State<ChaptersBookmarkScreen> {
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  bool isInterstitialLoaded = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    _initializeBannerAd();
    _initializeInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd.dispose();
    interstitialAd.dispose();
  }

  void _initializeBannerAd() async {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-9389901804535827/5411361970',
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

  void _initializeInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9389901804535827/8281628976',
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
    final BookmarksController bookmarksController = Get.find();
    bookmarksController.loadChaptersBookmark();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Chapters Bookmarks'),
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
      body: Obx(() {
        // final bookmarked = bookmarksController.chapters
        //     .where((chapter) => bookmarksController.bookmarkedChapters
        //     .contains(chapter['chapter_number'].toString()))
        //     .toList();

        // final bookmarked = bookmarksController.bookmarkedChapters
        //     .map((chapterNumber) => bookmarksController.chapters.firstWhere(
        //         (chapter) =>
        //     chapter['chapter_number'].toString() == chapterNumber))
        //     .toList();

        final bookmarkedSet = bookmarksController.bookmarkedChapters.toSet();
        final bookmarked = bookmarksController.chapters
            .where((chapter) =>
                bookmarkedSet.contains(chapter['chapter_number'].toString()))
            .toList();

        if (bookmarked.isEmpty) {
          return const EmptyBookmarks(msg: 'No bookmarked chapters');
        }
        return ListView.builder(
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
                leading:
                    CircleAvatar(child: Text('${chapter['chapter_number']}')),
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
        );
      }),
    );
  }
}
