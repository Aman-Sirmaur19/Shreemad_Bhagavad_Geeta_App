import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/api_service.dart';
import '../../widgets/empty_bookmarks.dart';
import '../../providers/bookmarks_provider.dart';
import '../tabs/verses/verse_screen.dart';

class VersesBookmarkScreen extends StatefulWidget {
  const VersesBookmarkScreen({super.key});

  @override
  State<VersesBookmarkScreen> createState() => _VersesBookmarkScreenState();
}

class _VersesBookmarkScreenState extends State<VersesBookmarkScreen> {
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
    final bookmarksProvider = Provider.of<BookmarksProvider>(context);
    bookmarksProvider.loadVersesBookmark();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Verses Bookmarks'),
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
      body: bookmarksProvider.bookmarkedVerses.isEmpty
          ? const EmptyBookmarks(msg: 'No bookmarked verses')
          : ListView.builder(
              itemCount: bookmarksProvider.bookmarkedVerses.keys.length,
              itemBuilder: (context, index) {
                final chapter = bookmarksProvider.chapters;
                final chapterNumber =
                    bookmarksProvider.bookmarkedVerses.keys.elementAt(index);
                final chapterName = utf8
                    .decode(chapter[int.parse(chapterNumber) - 1]['name']
                        .runes
                        .toList())
                    .trim();
                final verses = bookmarksProvider.bookmarkedVerses[chapterNumber]
                    as Map<dynamic, dynamic>;

                return Card(
                  color: Colors.brown,
                  child: ExpansionTile(
                    leading: CircleAvatar(child: Text(chapterNumber)),
                    title: Text(
                      chapterName,
                      style: TextStyle(
                          color: Colors.amber.shade200,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    children: verses.keys.map((verseNumber) {
                      return FutureBuilder<Map<String, dynamic>>(
                        future: ApiService()
                            .fetchParticularVerse(chapterNumber, verseNumber),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                              color: Colors.brown.shade400,
                              child: ListTile(
                                title: Text(
                                  'Loading...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade100,
                                  ),
                                ),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Card(
                              color: Colors.brown.shade400,
                              child: ListTile(
                                title: Text(
                                  'No internet connection  ᯤ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey.shade100,
                                  ),
                                ),
                                trailing: CupertinoButton(
                                  onPressed: () => setState(() {
                                    ApiService().fetchParticularVerse(
                                        chapterNumber, verseNumber);
                                  }),
                                  color: Colors.amber,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 7),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(
                                      letterSpacing: 2,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            final verseData = snapshot.data!;
                            final verseText = utf8
                                .decode(verseData['text'].runes.toList())
                                .trim();
                            return Card(
                              color: Colors.brown.shade400,
                              child: ListTile(
                                onTap: () {
                                  if (isInterstitialLoaded)
                                    interstitialAd.show();
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (_) => VerseScreen(
                                                chapterNumber: chapterNumber,
                                                verseNumber: verseNumber,
                                              )));
                                },
                                leading: CircleAvatar(child: Text(verseNumber)),
                                title: Text(
                                  verseText,
                                  style: TextStyle(
                                    height: 0.9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade400,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
    );
  }
}
