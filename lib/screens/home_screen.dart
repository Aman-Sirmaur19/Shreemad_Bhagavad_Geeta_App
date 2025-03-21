import 'dart:convert';
import 'dart:developer';
import 'dart:math' as m;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../secrets.dart';
import '../services/api_service.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/last_read_provider.dart';
import '../widgets/custom_banner_ad.dart';
import '../widgets/main_drawer.dart';
import '../widgets/internet_connectivity_button.dart';
import 'tabs/tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final FlutterTts textToSpeech = FlutterTts();
  late Future<List<dynamic>> chapters;
  bool isInterstitialLoaded = false;
  late InterstitialAd interstitialAd;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
    _initializeInterstitialAd();
    chapters = apiService.fetchChapters();
  }

  @override
  void dispose() {
    super.dispose();
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

  void _speak(String text) async {
    await textToSpeech.setLanguage('hi-IN');
    await textToSpeech.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider =
        Provider.of<BookmarksProvider>(context, listen: false);
    final lastReadProvider = Provider.of<LastReadProvider>(context);
    String lastReadSummary = lastReadProvider.lastReadChapter;
    String lastReadVerse = lastReadProvider.lastReadVerse;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/morpankh.png', width: 30),
              const Text(' श्रीमद्भगवद्गीता '),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(m.pi),
                child: Image.asset('assets/images/morpankh.png', width: 30),
              ),
            ],
          )),
      drawer: const MainDrawer(),
      bottomNavigationBar: const CustomBannerAd(),
      body: FutureBuilder<List<dynamic>>(
        future: chapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return InternetConnectivityButton(
                onPressed: () => setState(() {
                      chapters = apiService.fetchChapters();
                    }));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bookmarkProvider.setChapters(snapshot.data!);
            });
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Image.asset('assets/images/book.png', width: 140),
                      for (var chapter in snapshot.data!)
                        Card(
                          color: Colors.brown,
                          child: ListTile(
                            onTap: () {
                              // if (isInterstitialLoaded) interstitialAd.show();
                              Provider.of<LastReadProvider>(context,
                                      listen: false)
                                  .updateLastRead(
                                      chapter['chapter_number'].toString(), '');
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) =>
                                          TabScreen(chapter: chapter)));
                            },
                            leading: CircleAvatar(
                                child: Text('${chapter['chapter_number']}')),
                            title: Text(
                              utf8.decode(chapter['name'].runes.toList()),
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
                            // trailing: IconButton(
                            //   onPressed: () => _speak(
                            //       utf8.decode(chapter['name'].runes.toList())),
                            //   tooltip: 'Pronounce',
                            //   color: Colors.amber.shade200,
                            //   icon: const Icon(CupertinoIcons.speaker_2),
                            // ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    height: 130,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [
                              0,
                              .6,
                              1
                            ],
                            colors: [
                              Color(0xFFF9A602), // Bright Saffron Yellow
                              Color(0xFFFF7F11), // Reddish Saffron
                              Color(0xFFF36A1C), // Deep Saffron Orange
                            ])),
                    child: Row(
                      children: [
                        if (lastReadSummary == '')
                          RichText(
                            text: const TextSpan(
                              text: 'Start reading\n\n',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(
                                  text: 'THE DIVINE SONG\nOF GOD',
                                  style: TextStyle(
                                    fontSize: 17,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (lastReadSummary != '')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Last Read',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Chapter $lastReadSummary',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              if (lastReadVerse != '')
                                Text(
                                  'Verse $lastReadVerse',
                                  style: const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        const Spacer(),
                        Image.asset(
                          'assets/images/book.png',
                          width: 150,
                        )
                      ],
                    ),
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
