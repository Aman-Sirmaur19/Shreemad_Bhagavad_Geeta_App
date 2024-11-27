import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final dynamic chapter;

  const SummaryScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
          icon: const Icon(CupertinoIcons.chevron_back),
        ),
        title: Text('Chapter ${chapter['chapter_number']}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Text(
            utf8.decode(chapter['name'].runes.toList()),
            style: const TextStyle(
              fontSize: 22,
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            chapter['name_translated'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Text(
            'Verses: ${chapter['verses_count'].toString()}',
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
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            chapter['name_meaning'],
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
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            chapter['chapter_summary'],
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
