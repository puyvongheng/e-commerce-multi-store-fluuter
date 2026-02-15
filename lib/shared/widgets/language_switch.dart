import 'package:flutter/material.dart';

class LanguageSwitch extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const LanguageSwitch({
    super.key,
    required this.currentLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentLang,
      icon: const Icon(Icons.language),
      underline: const SizedBox(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      items: const [
        DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
        DropdownMenuItem(value: 'km', child: Text('🇰🇭 Khmer')),
      ],
    );
  }
}
