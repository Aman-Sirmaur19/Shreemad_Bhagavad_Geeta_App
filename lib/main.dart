import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'controllers/bookmarks_controller.dart';
import 'screens/home_screen.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMobileAds();
  await Hive.initFlutter();
  await Hive.openBox<String>('summaryBookmarks');
  await Hive.openBox<Map>('verseBookmarks');
  Get.put(BookmarksController());
  runApp(const MyApp());
}

void _initializeMobileAds() async {
  await MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shreemad Bhagwad Geeta',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 19,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.amber,
        ),
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.amber, background: Colors.amber.shade100),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
