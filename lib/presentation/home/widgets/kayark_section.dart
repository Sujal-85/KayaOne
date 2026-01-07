import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/core/theme/app_theme.dart';

class KayarkSection extends StatefulWidget {
  const KayarkSection({super.key});

  @override
  State<KayarkSection> createState() => _KayarkSectionState();
}

class _KayarkSectionState extends State<KayarkSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<String> _horizontalBanners = [
    'assets/kayark/banners-hori/banner_2026-01-07_12.37.04_.jpeg',
    'assets/kayark/banners-hori/banner_2026-01-07_12.37.07_1.jpeg',
    'assets/kayark/banners-hori/banner_2026-01-07_12.37.08_1.jpeg',
    'assets/kayark/banners-hori/banner_2026-01-07_12.37.08_.jpeg',
  ];

  final List<String> _verticalBanners = [
    'assets/kayark/banners-vertical/banner_2026-01-07_12.37.02_.jpeg',
    'assets/kayark/banners-vertical/banner_2026-01-07_12.37.03_.jpeg',
    'assets/kayark/banners-vertical/banner_2026-01-07_12.37.05_.jpeg',
    'assets/kayark/banners-vertical/banner_2026-01-07_12.37.06_.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    // Start at a high number to allow scrolling "backwards" effectively (though we only auto scroll forward)
    // But simpler is just 0 to infinity.
    _currentPage = 1000;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      }
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        // No setState needed for page change itself if using PageView,
        // but needed for indicator if we track it.
        // For indicator, we will use modulo.
        setState(() {});
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
    return Container(
      // Reduced margin to 0 to make it "attach to mobile edges" essentially full width or matching 1st card if it is full width
      // If 1st card in home_screen.dart (lines 596+) has no explicit margin, it follows parent padding.
      // Assuming parent CustomScrollView has no padding, 1st card is likely padded by internal padding of SliverToBoxAdapter or similar.
      // But here we are a widget in a list. Let's try margin: 0 to fill width, but maybe wrapping in padding is handled by caller.
      // Wait, earlier I added margin: 20. User complained. I will remove margin here and let parent handle it OR set to very small.
      // "same as 1st card". 1st card code viewed (lines 594-596) has `Padding(padding: fromLTRB(0,50,0,0)`.
      // It implies full width!
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Brand Header
            _buildBrandHeader(),

            const SizedBox(height: 8), // Reduced from 16

            // 2. Horizontal Banner Slider
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: null, // Infinite
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final realIndex = index % _horizontalBanners.length;
                  return _buildHorizontalBanner(_horizontalBanners[realIndex]);
                },
              ),
            ),

            const SizedBox(height: 8),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _horizontalBanners.length,
                (index) {
                  final realCurrent = _currentPage % _horizontalBanners.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: realCurrent == index ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: realCurrent == index
                          ? const Color(0xFF4B6309) // Olive Green
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 3. Vertical Banner Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Curated Collections",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          const Color(0xFF4B6309), // Darker Green for white bg
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Handpicked for your natural glow",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF4B6309).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4, // Show 4 items
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // Taller for vertical look
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return _buildVerticalBanner(
                          _verticalBanners[index], index);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero, // Removed padding completely
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF1F8E9), // Light Green/Beige
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Logo
          SizedBox(
            height: 280, // Increased size further to make it huge as requested
            width: double.infinity,
            child: Image.asset(
              'assets/kayark/image.png',
              fit: BoxFit
                  .cover, // Changed to cover (or contain if aspect ratio allows) to fill space
              // User said "space above and below... is not reduce".
              // If image has intrinsic whitespace, BoxFit.cover might crop it, which is good?
              // Or BoxFit.contain with tighter constraints.
              // Let's try BoxFit.contain but with zero padding in container.
            ),
          ).animate().fadeIn(duration: 800.ms).scale(duration: 600.ms),

          const SizedBox(height: 0), // Minimal spacing

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "100% Natural Handmade Herbal Cosmetic Products",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 32, // Increased font size
                  color: const Color(0xFF558B2F),
                  fontWeight: FontWeight.w700, // Slightly bolder
                  letterSpacing:
                      0.7, // Reduced letter spacing slightly to help fit
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildHorizontalBanner(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B6309).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.center,
                ),
              ),
            ),
            // CTA
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B6309),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Shop Now",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ).animate().scale(delay: 200.ms),
                ],
              ),
            ),
            // Tag
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      "Chemical Free",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalBanner(String imagePath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                index % 2 == 0 ? "Premium\nCollection" : "New\nArrivals",
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    height: 1.2),
              ),
            )
          ],
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn().slideY(begin: 0.2, end: 0);
  }
}
