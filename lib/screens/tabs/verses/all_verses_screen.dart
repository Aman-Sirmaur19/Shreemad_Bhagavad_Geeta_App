import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/ad_manager.dart';
import '../../../widgets/custom_banner_ad.dart';
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
                    Provider.of<LastReadProvider>(context, listen: false)
                        .updateLastRead(
                            widget.chapterNumber, (index + 1).toString());
                    AdManager().navigateWithAd(
                        context,
                        VerseScreen(
                          chapterNumber: widget.chapterNumber,
                          verseNumber: (index + 1).toString(),
                        ));
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
