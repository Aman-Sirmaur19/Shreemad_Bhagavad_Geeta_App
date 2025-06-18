import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/font_size_provider.dart';

class FontSizeSlider extends StatelessWidget {
  const FontSizeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.text_decrease),
          Expanded(
            child: Slider(
              min: 12,
              max: 30,
              divisions: 18,
              value: fontSizeProvider.fontSize,
              label: fontSizeProvider.fontSize.toStringAsFixed(0),
              onChanged: (value) => fontSizeProvider.setFontSize(value),
            ),
          ),
          const Icon(Icons.text_increase),
        ],
      ),
    );
  }
}
