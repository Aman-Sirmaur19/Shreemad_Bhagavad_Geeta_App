import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'summary_screen.dart';
import 'all_verses_screen.dart';

class TabScreen extends StatefulWidget {
  final String chapterNumber;
  final int numberOfVerses;

  const TabScreen({
    super.key,
    required this.chapterNumber,
    required this.numberOfVerses,
  });

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': SummaryScreen(chapterNumber: widget.chapterNumber),
        // 'title': 'Attendance Tracker',
      },
      {
        'page': AllVersesScreen(
          chapterNumber: widget.chapterNumber,
          numberOfVerses: widget.numberOfVerses,
        ),
        // 'title': 'Routine',
      },
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.shifting,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.pencil_outline),
            backgroundColor: Colors.black87,
            label: 'Summary',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.list_bullet_indent),
            label: 'Verses',
          ),
        ],
      ),
    );
  }
}
