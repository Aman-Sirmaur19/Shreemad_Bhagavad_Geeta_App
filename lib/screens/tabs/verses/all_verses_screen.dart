import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../providers/last_read_provider.dart';
import 'verse_screen.dart';

class AllVersesScreen extends StatefulWidget {
  final String chapterNumber;
  final int numberOfVerses;

  const AllVersesScreen(
      {super.key, required this.chapterNumber, required this.numberOfVerses});

  @override
  State<AllVersesScreen> createState() => _AllVersesScreenState();
}

class _AllVersesScreenState extends State<AllVersesScreen> {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Verses'),
      ),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
      body: ListView.builder(
        itemCount: widget.numberOfVerses,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              color: Colors.brown,
              child: ListTile(
                  onTap: () {
                    if (isInterstitialLoaded) interstitialAd.show();
                    Provider.of<LastReadProvider>(context, listen: false)
                        .updateLastRead(
                            widget.chapterNumber, (index + 1).toString());
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => VerseScreen(
                                  chapterNumber: widget.chapterNumber,
                                  verseNumber: (index + 1).toString(),
                                )));
                  },
                  title: Text(
                    'Verse ${index + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade200,
                    ),
                  )),
            ),
          );
        },
      ),
    );
  }
}
