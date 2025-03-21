import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../providers/last_read_provider.dart';
import '../../../secrets.dart';
import '../../../widgets/custom_banner_ad.dart';
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: const Text('Verses'),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.numberOfVerses,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              color: Colors.brown,
              child: ListTile(
                  onTap: () {
                    // if (isInterstitialLoaded) interstitialAd.show();
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
