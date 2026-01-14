import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kayaone/presentation/home/home_screen.dart';
import 'package:kayaone/presentation/prescription/prescription_upload_screen.dart';
import 'package:kayaone/presentation/marketplace/product_listing_screen.dart';

class AdvertisementCarousel extends StatefulWidget {
  const AdvertisementCarousel({super.key});

  @override
  State<AdvertisementCarousel> createState() => _AdvertisementCarouselState();
}

class _AdvertisementCarouselState extends State<AdvertisementCarousel> {
  late final PageController _pageController;
  int _currentPage = 1000; // Start in the middle for infinite scroll illusion

  final List<_AdData> _ads = [
    _AdData(
      title: "Book Free Home Visit",
      subtitle: "Comfort of your home, at no extra cost.",
      ctaText: "Book Now",
      colors: [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
      icon: Icons.home_work_outlined,
      iconColor: Colors.blueAccent, // Just for fallback/accent
      actionType: _AdActionType.homeVisit,
    ),
    // _AdData(
    //   title: "Flat 10% OFF on All Services",
    //   subtitle: "Get premium care at discounted rates.",
    //   ctaText: "Avail Offer",
    //   colors: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    //   icon: Icons.discount_outlined,
    //   iconColor: Colors.greenAccent,
    //   actionType: _AdActionType.generalServices,
    // ),
    // _AdData(
    //   title: "Doctor Consultation",
    //   subtitle: "Get 10–15% OFF on expert advice.",
    //   ctaText: "Book Now",
    //   colors: [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    //   icon: Icons.medical_services_outlined,
    //   iconColor: Colors.purpleAccent,
    //   actionType: _AdActionType.doctorConsult,
    // ),
    // _AdData(
    //   title: "10% OFF Medical Products",
    //   subtitle: "Essentials delivered to your door.",
    //   ctaText: "Shop Now",
    //   colors: [const Color(0xFFF2994A), const Color(0xFFF2C94C)],
    //   icon: Icons.shopping_bag_outlined,
    //   iconColor: Colors.orangeAccent,
    //   actionType: _AdActionType.products,
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAdTap(BuildContext context, _AdActionType type) {
    final homeState = HomeScreenState.of(context);
    switch (type) {
      case _AdActionType.homeVisit:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrescriptionUploadScreen()),
        );
        break;
      case _AdActionType.generalServices:
        // Navigate to Care/Lab tab
        homeState?.setIndex(1);
        break;
      case _AdActionType.doctorConsult:
        // Navigate to Doctor tab
        homeState?.setIndex(2);
        break;
      case _AdActionType.products:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListingScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final ad = _ads[index % _ads.length];
          return _AdCard(
            data: ad,
            onTap: () => _handleAdTap(context, ad.actionType),
          ).animate().fade(duration: 500.ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

enum _AdActionType { homeVisit, generalServices, doctorConsult, products }

class _AdData {
  final String title;
  final String subtitle;
  final String ctaText;
  final List<Color> colors;
  final IconData icon;
  final Color iconColor;
  final _AdActionType actionType;

  _AdData({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.colors,
    required this.icon,
    required this.iconColor,
    required this.actionType,
  });
}

class _AdCard extends StatelessWidget {
  final _AdData data;
  final VoidCallback onTap;

  const _AdCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: data.colors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              data.ctaText,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: data.colors.first,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
