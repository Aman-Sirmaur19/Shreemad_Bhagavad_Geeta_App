import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../widgets/custom_banner_ad.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({super.key});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<Map<String, String>> languages = [
    {"code": "af", "name": "Afrikaans"},
    {"code": "sq", "name": "Albanian"},
    {"code": "am", "name": "Amharic"},
    {"code": "ar", "name": "Arabic"},
    {"code": "hy", "name": "Armenian"},
    {"code": "az", "name": "Azerbaijani"},
    {"code": "eu", "name": "Basque"},
    {"code": "be", "name": "Belarusian"},
    {"code": "bn", "name": "Bengali"},
    {"code": "bs", "name": "Bosnian"},
    {"code": "bg", "name": "Bulgarian"},
    {"code": "ca", "name": "Catalan"},
    {"code": "ceb", "name": "Cebuano"},
    {"code": "ny", "name": "Chichewa"},
    {"code": "zh", "name": "Chinese (Simplified)"},
    {"code": "zh-TW", "name": "Chinese (Traditional)"},
    {"code": "co", "name": "Corsican"},
    {"code": "hr", "name": "Croatian"},
    {"code": "cs", "name": "Czech"},
    {"code": "da", "name": "Danish"},
    {"code": "nl", "name": "Dutch"},
    {"code": "en", "name": "English"},
    {"code": "eo", "name": "Esperanto"},
    {"code": "et", "name": "Estonian"},
    {"code": "tl", "name": "Filipino"},
    {"code": "fi", "name": "Finnish"},
    {"code": "fr", "name": "French"},
    {"code": "fy", "name": "Frisian"},
    {"code": "gl", "name": "Galician"},
    {"code": "ka", "name": "Georgian"},
    {"code": "de", "name": "German"},
    {"code": "el", "name": "Greek"},
    {"code": "gu", "name": "Gujarati"},
    {"code": "ht", "name": "Haitian Creole"},
    {"code": "ha", "name": "Hausa"},
    {"code": "haw", "name": "Hawaiian"},
    {"code": "iw", "name": "Hebrew"},
    {"code": "hi", "name": "Hindi"},
    {"code": "hmn", "name": "Hmong"},
    {"code": "hu", "name": "Hungarian"},
    {"code": "is", "name": "Icelandic"},
    {"code": "ig", "name": "Igbo"},
    {"code": "id", "name": "Indonesian"},
    {"code": "ga", "name": "Irish"},
    {"code": "it", "name": "Italian"},
    {"code": "ja", "name": "Japanese"},
    {"code": "jw", "name": "Javanese"},
    {"code": "kn", "name": "Kannada"},
    {"code": "kk", "name": "Kazakh"},
    {"code": "km", "name": "Khmer"},
    {"code": "rw", "name": "Kinyarwanda"},
    {"code": "ko", "name": "Korean"},
    {"code": "ku", "name": "Kurdish (Kurmanji)"},
    {"code": "ky", "name": "Kyrgyz"},
    {"code": "lo", "name": "Lao"},
    {"code": "la", "name": "Latin"},
    {"code": "lv", "name": "Latvian"},
    {"code": "lt", "name": "Lithuanian"},
    {"code": "lb", "name": "Luxembourgish"},
    {"code": "mk", "name": "Macedonian"},
    {"code": "mg", "name": "Malagasy"},
    {"code": "ms", "name": "Malay"},
    {"code": "ml", "name": "Malayalam"},
    {"code": "mt", "name": "Maltese"},
    {"code": "mi", "name": "Maori"},
    {"code": "mr", "name": "Marathi"},
    {"code": "mn", "name": "Mongolian"},
    {"code": "my", "name": "Myanmar (Burmese)"},
    {"code": "ne", "name": "Nepali"},
    {"code": "no", "name": "Norwegian"},
    {"code": "or", "name": "Odia (Oriya)"},
    {"code": "ps", "name": "Pashto"},
    {"code": "fa", "name": "Persian"},
    {"code": "pl", "name": "Polish"},
    {"code": "pt", "name": "Portuguese"},
    {"code": "pa", "name": "Punjabi"},
    {"code": "ro", "name": "Romanian"},
    {"code": "ru", "name": "Russian"},
    {"code": "sm", "name": "Samoan"},
    {"code": "gd", "name": "Scots Gaelic"},
    {"code": "sr", "name": "Serbian"},
    {"code": "st", "name": "Sesotho"},
    {"code": "sn", "name": "Shona"},
    {"code": "sd", "name": "Sindhi"},
    {"code": "si", "name": "Sinhala"},
    {"code": "sk", "name": "Slovak"},
    {"code": "sl", "name": "Slovenian"},
    {"code": "so", "name": "Somali"},
    {"code": "es", "name": "Spanish"},
    {"code": "su", "name": "Sundanese"},
    {"code": "sw", "name": "Swahili"},
    {"code": "sv", "name": "Swedish"},
    {"code": "tg", "name": "Tajik"},
    {"code": "ta", "name": "Tamil"},
    {"code": "tt", "name": "Tatar"},
    {"code": "te", "name": "Telugu"},
    {"code": "th", "name": "Thai"},
    {"code": "tr", "name": "Turkish"},
    {"code": "tk", "name": "Turkmen"},
    {"code": "uk", "name": "Ukrainian"},
    {"code": "ur", "name": "Urdu"},
    {"code": "ug", "name": "Uyghur"},
    {"code": "uz", "name": "Uzbek"},
    {"code": "vi", "name": "Vietnamese"},
    {"code": "cy", "name": "Welsh"},
    {"code": "xh", "name": "Xhosa"},
    {"code": "yi", "name": "Yiddish"},
    {"code": "yo", "name": "Yoruba"},
    {"code": "zu", "name": "Zulu"},
  ];

  List<Map<String, String>> filteredLanguages = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredLanguages = List.from(languages);
  }

  void _filterLanguages(String query) {
    setState(() {
      filteredLanguages = languages
          .where((lang) =>
              lang["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var languageProvider = Provider.of<LanguageProvider>(context);
    String selectedLangName = languages.firstWhere(
            (lang) => lang["code"] == languageProvider.selectedLanguage,
            orElse: () => {"name": "None"})["name"] ??
        "None";
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
            icon: const Icon(CupertinoIcons.chevron_back),
          ),
          title: const Text('Languages'),
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 150),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const Text(
                    "Select Language",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "(only for Summary & Verse description)",
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Language",
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: _filterLanguages,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                        text: TextSpan(
                      text: 'Selected:  ',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                            text: selectedLangName,
                            style: const TextStyle(
                              fontSize: 18,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ))
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredLanguages.length,
          itemBuilder: (context, index) {
            String langCode = filteredLanguages[index]["code"]!;
            String langName = filteredLanguages[index]["name"]!;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: CheckboxListTile(
                activeColor: Colors.green,
                tileColor: languageProvider.selectedLanguage == langCode
                    ? Colors.brown
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.brown),
                ),
                title: Text(
                  langName,
                  style: TextStyle(
                    fontWeight: languageProvider.selectedLanguage == langCode
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: languageProvider.selectedLanguage == langCode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                value: languageProvider.selectedLanguage == langCode,
                onChanged: (bool? selected) {
                  if (selected == true) {
                    languageProvider.setLanguage(langCode, langName);
                    selectedLangName = langName;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Language set to $selectedLangName',
                                style: const TextStyle(
                                    letterSpacing: 1, color: Colors.white)),
                            const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomBannerAd(),
      ),
    );
  }
}
