import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class VerseScreen extends StatefulWidget {
  final String chapterNumber;
  final String verseNumber;

  const VerseScreen({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
  });

  @override
  State<VerseScreen> createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> verse;

  @override
  void initState() {
    super.initState();
    verse = apiService.fetchParticularVerse(
      widget.chapterNumber,
      widget.verseNumber,
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
        title: Text('Verse ${widget.verseNumber}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: verse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final item = snapshot.data!;
            final translation = (item['translations'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Tejomayananda',
              orElse: () => null, // Handle the case where no match is found
            );
            final commentary = (item['commentaries'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Chinmayananda',
              orElse: () => null, // Handle the case where no match is found
            );
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Text(
                  utf8.decode(item['text'].runes.toList()).trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const Text('Translation:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  utf8.decode(translation['description'].runes.toList()).trim(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const Text('Description:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
                Text(
                  utf8.decode(commentary['description'].runes.toList()).trim(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
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
