import 'dart:convert';
import 'package:http/http.dart' as http;

import '../secrets.dart';

class ApiService {
  static const String baseUrl =
      'https://bhagavad-gita3.p.rapidapi.com/v2/chapters/';
  static const String apiKey = Secrets.apiKey;
  static const String apiHost = 'bhagavad-gita3.p.rapidapi.com';

  Future<List<dynamic>> fetchChapters() async {
    final url = Uri.parse('$baseUrl?skip=0&limit=18');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchParticularChapter(
      String chapterNumber) async {
    final url = Uri.parse('$baseUrl$chapterNumber/');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> fetchVerses(String verseNumber) async {
    final url = Uri.parse('$baseUrl$verseNumber/verses/');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchParticularVerse(
      String chapterNumber, String verseNumber) async {
    final url = Uri.parse('$baseUrl$chapterNumber/verses/$verseNumber/');
    try {
      final response = await http.get(
        url,
        headers: {
          'x-rapidapi-key': apiKey,
          'x-rapidapi-host': apiHost,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
