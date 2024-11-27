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
            final hindiTranslation = (item['translations'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Tejomayananda',
              orElse: () => null,
            );
            final englishTranslation =
                (item['translations'] as List).firstWhere(
              (t) => t['author_name'] == 'Shri Purohit Swami',
              orElse: () => null,
            );
            final hindiCommentary = (item['commentaries'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Chinmayananda',
              orElse: () => null,
            );
            final englishCommentary = (item['commentaries'] as List).firstWhere(
              (t) => t['author_name'] == 'Swami Sivananda',
              orElse: () => null,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 5),
                Text(
                  '${utf8.decode(hindiTranslation['description'].runes.toList()).trim()}\n\n${utf8.decode(englishTranslation['description'].runes.toList()).trim()}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const Text('Description:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 5),
                Text(
                  utf8
                      .decode(hindiCommentary['description'].runes.toList())
                      .trim(),
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
