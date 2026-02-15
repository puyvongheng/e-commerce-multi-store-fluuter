import 'package:flutter/material.dart';
import 'package:app1/models/store.dart';
import 'package:app1/l10n/app_localizations.dart';

class StoreProfileBottomBar extends StatelessWidget {
  final Store store;
  final bool isDark;
  final bool isFollowing;
  final VoidCallback onChatTap;
  final VoidCallback onFollowTap;

  const StoreProfileBottomBar({
    super.key,
    required this.store,
    required this.isDark,
    required this.isFollowing,
    required this.onChatTap,
    required this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const Color lazadaOrange = Color(0xFFFF6600);
    // ពណ៌ទឹកដោះគោខាប់
    // ពណ៌កាហ្វេ

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 1. Chat Button (Creamy Style)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: lazadaOrange, // រក្សាផ្ទៃពណ៌ទឹកដោះគោខាប់ (Creamy)
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: onChatTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Telegram (Send Icon)
                        const Icon(
                          Icons.send_rounded,
                          color: Color.fromARGB(
                              255, 255, 255, 255), // ពណ៌ Telegram (Blue)
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        // Text ពណ៌ Telegram ដែរ
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
