import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/slide.dart';

class ImageCarousel extends StatefulWidget {
  final List<Slide> slides;
  final double height;
  final bool autoPlay;

  const ImageCarousel({
    super.key,
    required this.slides,
    this.height = 200, // Slightly increased default height
    this.autoPlay = true,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Use 1.0 for full width or close to it for a "friendly" responsive look
    _pageController = PageController(viewportFraction: 0.92);

    if (widget.autoPlay && widget.slides.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % widget.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive height calculation
    double responsiveHeight = widget.height;
    if (screenWidth > 600) {
      responsiveHeight = 300;
    }
    if (screenWidth > 1100) {
      responsiveHeight = 400;
    }

    return Column(
      children: [
        SizedBox(
          height: responsiveHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4), // Minimal gap
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        slide.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: isDark ? Colors.grey[850] : Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFF6600),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[850] : Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: isDark ? Colors.white24 : Colors.grey[400],
                              size: 40,
                            ),
                          );
                        },
                      ),

                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.0),
                              Colors.black.withOpacity(0.6),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Indicator
        SmoothPageIndicator(
          controller: _pageController,
          count: widget.slides.length,
          effect: ExpandingDotsEffect(
            activeDotColor: const Color(0xFFFF6600),
            dotColor: isDark ? Colors.white24 : Colors.grey[300]!,
            dotHeight: 6,
            dotWidth: 6,
            spacing: 6,
            expansionFactor: 4,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}
