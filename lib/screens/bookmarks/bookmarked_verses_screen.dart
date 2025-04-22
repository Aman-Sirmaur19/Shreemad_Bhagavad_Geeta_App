import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ad_manager.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_banner_ad.dart';
import '../../widgets/empty_bookmarks.dart';
import '../../providers/bookmarks_provider.dart';
import '../tabs/verses/verse_screen.dart';

class BookmarkedVersesScreen extends StatefulWidget {
  const BookmarkedVersesScreen({super.key});

  @override
  State<BookmarkedVersesScreen> createState() => _BookmarkedVersesScreenState();
}

class _BookmarkedVersesScreenState extends State<BookmarkedVersesScreen> {
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
        title: const Text('Bookmarked Verses'),
      ),
      bottomNavigationBar: const CustomBannerAd(),
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
                    shape: const RoundedRectangleBorder(side: BorderSide.none),
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
                                onTap: () => AdManager().navigateWithAd(
                                    context,
                                    VerseScreen(
                                      chapterNumber: chapterNumber,
                                      verseNumber: verseNumber,
                                    )),
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
