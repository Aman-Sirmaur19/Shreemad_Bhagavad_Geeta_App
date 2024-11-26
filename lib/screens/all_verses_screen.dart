import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/main_drawer.dart';
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
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> verses;

  @override
  void initState() {
    super.initState();
    verses = apiService.fetchVerses(widget.chapterNumber);
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
      drawer: const MainDrawer(),
      body: ListView.builder(
        itemCount: widget.numberOfVerses,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              child: ListTile(
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => VerseScreen(
                                chapterNumber: widget.chapterNumber,
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
