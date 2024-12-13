import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bookmarked_chapters_screen.dart';
import 'bookmarked_verses_screen.dart';

class BookmarksTabScreen extends StatefulWidget {
  const BookmarksTabScreen({super.key});

  @override
  State<BookmarksTabScreen> createState() => _BookmarksTabScreenState();
}

class _BookmarksTabScreenState extends State<BookmarksTabScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': const BookmarkedChaptersScreen(),
      },
      {
        'page': const BookmarkedVersesScreen(),
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
            icon: Icon(CupertinoIcons.list_bullet_indent),
            backgroundColor: Colors.black87,
            label: 'Chapters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            backgroundColor: Colors.black87,
            label: 'Verses',
          ),
        ],
      ),
    );
  }
}
