import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA);
    final textColor = isDark ? Colors.grey[300] : Colors.grey[800];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Privacy Policy",
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
            Text(
              "Last updated: Feb 01, 2026",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildSection(
              "1. Introduction",
              "Welcome to My E-Shop. We value your privacy and are committed to protecting your personal data.",
              textColor,
            ),
            _buildSection(
              "2. Data We Collect",
              "We collect personal information such as your name, email address, phone number, and shipping address when you register or place an order. We also collect usage data to improve our services.",
              textColor,
            ),
            _buildSection(
              "3. How We Use Your Data",
              "Your data is used to process orders, manage your account, providing customer support, and send promotional emails (if opted in).",
              textColor,
            ),
            _buildSection(
              "4. Data Security",
              "We implement advanced security measures to protect your data. However, no method of transmission over the Internet is 100% secure.",
              textColor,
            ),
            _buildSection(
              "5. Contact Us",
              "If you have any questions about this Privacy Policy, please contact us at privacy@eshop.com.",
              textColor,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(color: textColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
