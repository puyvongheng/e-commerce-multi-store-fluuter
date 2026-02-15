import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/l10n/app_localizations.dart';

class ProductDetailDescriptionSection extends StatelessWidget {
  final String description;
  final int salesCount;
  final bool isDark;

  const ProductDetailDescriptionSection({
    super.key,
    required this.description,
    required this.salesCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate('product_details'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ..._buildMarkdown(context, description),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  List<Widget> _buildMarkdown(BuildContext context, String text) {
    if (text.isEmpty) return [];

    final lines = text.split('\n');
    List<Widget> children = [];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 8));
        continue;
      }

      // Headers
      if (line.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: _richText(context, line.substring(4),
              fontSize: 16, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('## ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: _richText(context, line.substring(3),
              fontSize: 18, fontWeight: FontWeight.bold),
        ));
      } else if (line.startsWith('# ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: _richText(context, line.substring(2),
              fontSize: 22, fontWeight: FontWeight.bold),
        ));
      }
      // Lists
      else if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ",
                  style: TextStyle(
                      color: isDark ? Colors.orange[400] : Colors.orange[700],
                      fontWeight: FontWeight.bold)),
              Expanded(child: _richText(context, line.trim().substring(2))),
            ],
          ),
        ));
      }
      // Regular Text
      else {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _richText(context, line),
        ));
      }
    }

    return children;
  }

  Widget _richText(BuildContext context, String text,
      {double fontSize = 14, FontWeight? fontWeight}) {
    List<TextSpan> spans = [];

    // Simple inline parser for **bold** and *italic*
    final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*)');
    final matches = regex.allMatches(text);

    int lastMatchEnd = 0;
    for (var match in matches) {
      // Add plain text before match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      String matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold, color: null),
        ));
      } else if (matchText.startsWith('*') && matchText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }

      lastMatchEnd = match.end;
    }

    // Add remaining plain text
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          height: 1.6,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        children: spans,
      ),
    );
  }
}
