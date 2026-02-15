import 'package:app1/features/profile/presentation/pages/alphabet_learning_page.dart';
import 'package:app1/features/profile/presentation/pages/angkor_run_page.dart';
import 'package:app1/features/profile/presentation/pages/candy_game_page.dart';
import 'package:app1/features/profile/presentation/pages/fishing_game_page.dart';
import 'package:app1/features/profile/presentation/pages/khmer_empire_game_page.dart';
import 'package:app1/features/profile/presentation/pages/khmer_hill_rider_page.dart';
import 'package:app1/features/profile/presentation/pages/khmer_quiz_page.dart';
import 'package:app1/features/profile/presentation/pages/kla_klouk_game_page.dart';
import 'package:app1/features/settings/address/presentation/pages/address_page.dart';
import 'package:app1/features/profile/presentation/widgets/profile_menu_icon.dart';
import 'package:app1/features/settings/presentation/pages/settings_page.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileUtilityGrid extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileUtilityGrid({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        runSpacing: 25,
        alignment: WrapAlignment.start,
        children: [
          ProfileMenuIcon(
              icon: Icons.location_on_rounded,
              label: t.translate('address'),
              color: Colors.deepOrange,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddressListPage()))),
          ProfileMenuIcon(
              icon: Icons.castle_rounded,
              label: 'Khmer Empire',
              color: Colors.brown,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const KhmerEmpireGamePage()))),
          ProfileMenuIcon(
              icon: Icons.directions_run_rounded,
              label: 'Angkor Run',
              color: Colors.green,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AngkorRunPage()))),
          ProfileMenuIcon(
              icon: Icons.auto_awesome_rounded,
              label: 'Candy Dash',
              color: Colors.purple,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CandyGamePage()))),
          ProfileMenuIcon(
              icon: Icons.terrain_rounded,
              label: 'Hill Rider',
              color: Colors.greenAccent,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const KhmerHillRiderPage()))),
          ProfileMenuIcon(
              icon: Icons.abc_rounded,
              label: 'ABC Learning',
              color: Colors.pinkAccent,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AlphabetLearningPage()))),
          ProfileMenuIcon(
              icon: Icons.quiz_rounded,
              label: 'និទានបណ្តៅ',
              color: Colors.teal,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KhmerQuizPage()))),
          ProfileMenuIcon(
              icon: Icons.casino_rounded,
              label: 'ខ្លាឃ្លោក',
              color: Colors.redAccent,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const KlaKloukGamePage()))),
          ProfileMenuIcon(
              icon: Icons.phishing_rounded,
              label: 'បាគត្រី',
              color: Colors.cyan,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FishingGamePage()))),
          ProfileMenuIcon(
            svgPath: 'assets/icons/setting.svg',
            label: t.translate('setting'),
            width: MediaQuery.of(context).size.width / 4.5,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                  onThemeToggle: () {
                    // TODO: toggle theme here
                    print('Theme toggled');
                  },
                  onLanguageChange: (String langCode) {
                    // TODO: change language here
                    print('Language changed to $langCode');
                  },
                ),
              ),
            ),
          ),
          ProfileMenuIcon(
              icon: Icons.logout_rounded,
              label: t.translate('log_out'),
              color: Colors.redAccent,
              width: MediaQuery.of(context).size.width / 4.5,
              onTap: onLogout),
        ],
      ),
    );
  }
}
