import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app1/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/features/product/presentation/pages/flash_sale_page.dart';

class FlashSaleBanner extends StatefulWidget {
  const FlashSaleBanner({super.key});

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner> {
  late Timer _timer;
  Duration _remainingTime = const Duration(hours: 2, minutes: 45, seconds: 30);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isSmall = width < 360;
        final bool isTablet = width > 600;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FlashSalePage(),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFE3F30), Color(0xFFFF7B54)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.flash_on_rounded,
                        size: isTablet ? 200 : 150, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 30 : 20,
                    vertical: isTablet ? 24 : 16,
                  ),
                  child: Row(
                    children: [
                      // Title Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.flash_on_rounded,
                                        color: Colors.yellow, size: 24)
                                    .animate(onPlay: (c) => c.repeat())
                                    .fadeIn(duration: 600.ms)
                                    .then()
                                    .fadeOut(duration: 600.ms),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    t.translate('flash_sale'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          isTablet ? 24 : (isSmall ? 16 : 18),
                                      fontWeight: FontWeight.w900,
                                      fontStyle: FontStyle.italic,
                                      shadows: const [
                                        Shadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2))
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ends in",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Countdown Timer
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTimerUnit(
                              _formatTwoDigits(_remainingTime.inHours),
                              isTablet),
                          _buildSeparator(),
                          _buildTimerUnit(
                              _formatTwoDigits(
                                  _remainingTime.inMinutes.remainder(60)),
                              isTablet),
                          _buildSeparator(),
                          _buildTimerUnit(
                              _formatTwoDigits(
                                  _remainingTime.inSeconds.remainder(60)),
                              isTablet),
                        ],
                      ),

                      if (!isSmall) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        );
      },
    );
  }

  String _formatTwoDigits(int n) => n.toString().padLeft(2, '0');

  Widget _buildTimerUnit(String value, bool isLarge) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Text(
        value,
        style: TextStyle(
          color: const Color(0xFFFE3F30),
          fontSize: isLarge ? 18 : 14,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: const Text(
        ":",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
