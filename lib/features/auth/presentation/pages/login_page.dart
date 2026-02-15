import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app1/services/auth_service.dart';
import '../../../layout/presentation/pages/main_layout.dart';
import '../widgets/lazada_text_field.dart';
import '../widgets/lazada_button.dart';
import '../widgets/social_login_buttons.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  static const Color primaryColor = Color(0xFFFF6600);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.login(email, password);

      if (data['success'] == true && data['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        final user = data['user'];
        await prefs.setString('token', user['id'].toString());
        await prefs.setString('user_data', jsonEncode(user));

        if (!mounted) return;

        _showMessage('Welcome back!', isError: false);

        if (widget.onLoginSuccess != null) {
          widget.onLoginSuccess!();
        } else {
          // Avoid pushing MyApp() to prevent "Duplicate GlobalKey" from nested GetMaterialApp.
          // Fallback to MainLayout with dummy callbacks if onLoginSuccess is missing.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(
                isDarkMode: false,
                onThemeToggle: () {},
                onLanguageChange: (_) {},
              ),
            ),
          );
        }
      } else {
        _showMessage(data['message'] ?? 'Login failed', isError: true);
      }
    } catch (e) {
      _showMessage('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: size.height,
            child: isDesktop
                ? Row(
                    children: [
                      // Left Side - Illustration
                      Expanded(
                        child: Center(
                          child: _buildIllustration(),
                        ),
                      ),
                      // Right Side - Form
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32),
                            child: _buildLoginForm(isDark),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: _buildLoginForm(isDark, showImage: false),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Image.asset(
      'assets/images/login_illustration.png',
      height: 400, // Larger for desktop
      fit: BoxFit.contain,
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .scale(curve: Curves.easeOutBack, begin: const Offset(0.8, 0.8));
  }

  Widget _buildLoginForm(bool isDark, {bool showImage = true}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showImage) ...[
          // For mobile if we wanted it, but user requested NO image on mobile.
          // Keeping this logic flexible if requirements change, but defaulting strictly as requested.
        ],

        // Header Text
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF2D3436),
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 8),

        Text(
          'Login to continue shopping',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 40),

        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              LazadaTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              LazadaTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscureText: true,
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() => _rememberMe = value ?? false);
                        },
                        activeColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 24),
              LazadaButton(
                text: 'Login',
                onPressed: _login,
                isLoading: _isLoading,
              ).animate().fadeIn(delay: 700.ms).scale(
                  begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 900.ms),
            ],
          ),
        ),
      ],
    );
  }
}
