import 'dart:async'; // 🔥 ត្រូវការសម្រាប់ Timer
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'features/layout/presentation/pages/main_layout.dart';
import 'features/auth/presentation/pages/login_page.dart';

import 'features/layout/presentation/widgets/splash_screen.dart';

// --- MAIN APP ---

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String _currentLang = 'en';
  bool _isLoading = true;
  bool _isLoggedIn = false;
  bool _showSplash = true; // 🔥 Variable សម្រាប់គ្រប់គ្រង Splash Screen

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _isLoading = false; // Data load ចប់ហើយ
      });
    }
  }

  void _onSplashFinished() {
    setState(() {
      _showSplash = false; // បិទ Splash Screen ចេញ
    });
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);
  void _changeLanguage(String lang) {
    setState(() => _currentLang = lang);
    Get.updateLocale(Locale(lang));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(_currentLang),
      supportedLocales: const [Locale('en'), Locale('km')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Flutter E-Commerce',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🔥 Logic ការបង្ហាញផ្ទាំង
      home: _showSplash
          ? SplashScreen(onFinish: _onSplashFinished) // បង្ហាញ Splash មុនគេ
          : _isLoading
              ? const Scaffold(
                  body: Center(
                      child:
                          CircularProgressIndicator())) // ការពារករណី Load Data យឺតជាង Splash
              : _isLoggedIn
                  ? MainLayout(
                      isDarkMode: _isDarkMode,
                      onThemeToggle: _toggleTheme,
                      onLanguageChange: _changeLanguage,
                    )
                  : LoginPage(onLoginSuccess: _checkLoginStatus),
    );
  }
}
