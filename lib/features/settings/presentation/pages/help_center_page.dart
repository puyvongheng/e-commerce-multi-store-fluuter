import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA);
    final cardColor = isDark ? const Color(0xFF1E2026) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Help Center",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Frequently Asked Questions", isDark),
            const SizedBox(height: 12),
            _buildFaqItem(
              "How to track my order?",
              "Go to 'My Orders' in your profile to see real-time status updates.",
              cardColor,
              isDark,
            ),
            _buildFaqItem(
              "How to return an item?",
              "You can request a return within 7 days of delivery via the Order Details page.",
              cardColor,
              isDark,
            ),
            _buildFaqItem(
              "What payment methods are supported?",
              "We accept Visa, MasterCard, KHQR, and Cash on Delivery.",
              cardColor,
              isDark,
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Still need help?", isDark),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.telegram,
              title: "Chat on Telegram",
              subtitle: "Average wait time: 5 mins",
              color: Colors.blue,
              cardColor: cardColor,
              onTap: () => _launchUrl('https://t.me/support_bot'),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@eshop.com",
              color: Colors.red,
              cardColor: cardColor,
              onTap: () => _launchUrl('mailto:support@eshop.com'),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle("Our Office Location", isDark),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              icon: Icons.map_outlined,
              title: "View on Google Maps",
              subtitle: "13.545228, 103.064044",
              color: Colors.green,
              cardColor: cardColor,
              onTap: () => _launchUrl(
                  'https://www.google.com/maps/search/?api=1&query=13.545228,103.064044'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildFaqItem(
      String question, String answer, Color cardColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildContactCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required Color cardColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Future<void> _launchUrl(String urlString) async {
    if (await canLaunchUrl(Uri.parse(urlString))) {
      await launchUrl(Uri.parse(urlString));
    }
  }
}
