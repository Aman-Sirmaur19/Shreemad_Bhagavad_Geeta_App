import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/main_drawer.dart';
import 'verse_screen.dart';

class AllVersesScreen extends StatelessWidget {
  final String chapterNumber;
  final int numberOfVerses;

  const AllVersesScreen(
      {super.key, required this.chapterNumber, required this.numberOfVerses});

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
      drawer: const MainDrawer(),
      body: ListView.builder(
        itemCount: numberOfVerses,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => VerseScreen(
                                chapterNumber: chapterNumber,
                                verseNumber: (index + 1).toString(),
                              ))),
                  title: Text(
                    'Verse ${index + 1}',
                  )),
            ),
          );
        },
      ),
    );
  }
}
