import 'package:app1/features/auth/presentation/pages/login_page.dart';
import 'package:app1/features/settings/address/presentation/pages/address_page.dart';
import 'package:app1/features/settings/presentation/widgets/language_selector_sheet.dart';
import 'package:app1/features/settings/presentation/widgets/settings_item.dart';
import 'package:app1/features/settings/presentation/pages/help_center_page.dart';
import 'package:app1/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:app1/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:app1/features/settings/presentation/widgets/settings_toggle.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;

  const SettingsPage({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageChange,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // bool _notificationsEnabled = true; // Not currently used in the requested layout, but keeping commented if needed later or removing if safe. Removing since it was only used in the removed toggle code in previous iterations but might be relevant? The user removed it in previous diffs? Wait, my view_file showed it around line 23. But the USER removed the boolean usage in previous edit? No, line 23 was there. But the UI usage was removed in Step 57! So I can remove it.

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(
        onLanguageChange: widget.onLanguageChange,
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(t.translate('settings'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 20, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 10),

            SettingsItem(
              icon: Icons.location_on_outlined,
              title: t.translate('shipping_address'),
              subtitle: t.translate('address_subtitle'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddressListPage()));
              },
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            SettingsItem(
              icon: Icons.language_rounded,
              title: t.translate('language'),
              subtitle: Localizations.localeOf(context).languageCode == 'km'
                  ? t.translate('khmer')
                  : t.translate('english'),
              onTap: () => _showLanguageSelector(context),
              color: Colors.cyan,
            ),
            SettingsToggle(
              icon: Icons.dark_mode_outlined,
              title: t.translate('dark_mode'),
              value: isDark,
              onChanged: (val) => widget.onThemeToggle(),
              color: Colors.indigo,
            ),

            const SizedBox(height: 20),

            // 3. Support Section
            SettingsSectionHeader(title: t.translate('reach_us')),
            SettingsItem(
              icon: Icons.help_outline_rounded,
              title: t.translate('help_center'),
              subtitle: t.translate('help_subtitle'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HelpCenterPage()));
              },
              color: Colors.amber,
            ),
            SettingsItem(
              icon: Icons.info_outline_rounded,
              title: t.translate('privacy_policy'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage()));
              },
              color: Colors.grey,
            ),

            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _logout,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(t.translate('log_out'),
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Text("Version 1.0.2 (Build 2026)",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
