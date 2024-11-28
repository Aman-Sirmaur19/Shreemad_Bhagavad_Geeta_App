import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';

import '../services/api_service.dart';
import '../widgets/main_drawer.dart';
import 'tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> chapters;
  final FlutterTts textToSpeech = FlutterTts();
  bool isBannerLoaded = false;
  late BannerAd bannerAd;
  bool isInterstitialLoaded = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _initializeBannerAd();
    _initializeInterstitialAd();
    chapters = apiService.fetchChapters();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd.dispose();
    interstitialAd.dispose();
  }

  Future<void> _checkForUpdate() async {
    log('Checking for Update!');
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        if (info.updateAvailability == UpdateAvailability.updateAvailable) {
          log('Update available!');
          update();
        }
      });
    }).catchError((error) {
      log(error.toString());
    });
  }

  void update() async {
    log('Updating');
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      log(error.toString());
    });
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

  void _speak(String text) async {
    await textToSpeech.setLanguage('hi-IN');
    await textToSpeech.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/morpankh.png', width: 30),
              const Text(' श्रीमद्भगवद्गीता '),
              Image.asset('assets/images/morpankh.png', width: 30),
            ],
          )),
      drawer: const MainDrawer(),
      bottomNavigationBar: isBannerLoaded
          ? SizedBox(height: 50, child: AdWidget(ad: bannerAd))
          : null,
      body: FutureBuilder<List<dynamic>>(
        future: chapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final chapter = snapshot.data![index];
                final chapterName = utf8.decode(chapter['name'].runes.toList());
                return Card(
                  child: ListTile(
                    onTap: () {
                      if (isInterstitialLoaded) interstitialAd.show();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => TabScreen(chapter: chapter)));
                    },
                    leading: CircleAvatar(
                        child: Text('${chapter['chapter_number']}')),
                    title: Text(
                      chapterName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter['name_translated'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Verses: ${chapter['verses_count']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () => _speak(chapterName),
                      tooltip: 'Pronounce',
                      icon: const Icon(CupertinoIcons.speaker_2),
                    ),
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
