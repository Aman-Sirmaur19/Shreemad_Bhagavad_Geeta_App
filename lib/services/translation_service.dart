import 'package:translator/translator.dart';

class TranslationService {
  static final translator = GoogleTranslator();

  /// Translates text from one language to another
  static Future<String> translate(String text, String toLang) async {
    try {
      final translated = await translator.translate(text, to: toLang);
      return translated.text;
    } catch (e) {
      return "Translation Error: $e";
    }
  }
}
