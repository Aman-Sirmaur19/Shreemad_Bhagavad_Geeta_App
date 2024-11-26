import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    chapters = apiService.fetchChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('श्रीमद्भगवद्गीता')),
      drawer: const MainDrawer(),
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
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => TabScreen(
                                  chapterNumber:
                                      chapter['chapter_number'].toString(),
                                  numberOfVerses: chapter['verses_count'],
                                ))),
                    leading: CircleAvatar(
                        child: Text('${chapter['chapter_number']}')),
                    title: Text(
                      utf8.decode(chapter['name'].runes.toList()),
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
                      onPressed: () {},
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
