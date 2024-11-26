import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SummaryScreen extends StatefulWidget {
  final String chapterNumber;

  const SummaryScreen({super.key, required this.chapterNumber});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final ApiService apiService = ApiService();
  late Future<Map<String, dynamic>> chapter;

  @override
  void initState() {
    super.initState();
    chapter = apiService.fetchParticularChapter(widget.chapterNumber);
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
        title: Text('Chapter ${widget.chapterNumber}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: chapter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final item = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Text(
                  utf8.decode(item['name'].runes.toList()),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['name_translated'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Text(
                  'Verses: ${item['verses_count'].toString()}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const Text(
                  'Meaning:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['name_meaning'],
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const Text(
                  'Summary:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item['chapter_summary'],
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black54,
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
