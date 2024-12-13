import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'screens/home_screen.dart';
import 'providers/last_read_provider.dart';
import 'providers/bookmarks_provider.dart';

late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMobileAds();
  await Hive.initFlutter();
  await Hive.openBox<String>('summaryBookmarks');
  await Hive.openBox<Map>('verseBookmarks');
  await Hive.openBox('lastReadBox');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LastReadProvider()),
      ChangeNotifierProvider(create: (_) => BookmarksProvider()),
    ],
    child: const MyApp(),
  ));
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
      title: 'Shreemad Bhagavad Geeta',
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
