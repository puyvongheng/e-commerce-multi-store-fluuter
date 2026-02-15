import 'package:flutter/material.dart';

class ThemeSwitch extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onChanged;

  const ThemeSwitch({
    super.key,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
        Switch(
          value: isDarkMode,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
