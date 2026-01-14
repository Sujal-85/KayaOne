import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/data/services/notification_service.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

import 'package:kayaone/presentation/home/notifications_screen.dart';
import 'package:kayaone/presentation/home/widgets/home_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'dart:ui';

import 'package:kayaone/presentation/prescription/prescription_upload_screen.dart';
import 'package:kayaone/presentation/booking/my_appointments_screen.dart';
import 'package:kayaone/presentation/healthkarma/health_karma_screen.dart';
import 'package:kayaone/presentation/marketplace/product_listing_screen.dart';
import 'package:kayaone/presentation/doctors/doctor_listing_screen.dart';
import 'package:kayaone/presentation/auth/login_screen.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/state/health_karma_provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/booking/address_selection_screen.dart';
import 'package:kayaone/data/services/booking_service.dart';
import 'package:kayaone/presentation/profile/profile_screen.dart';

import 'package:kayaone/state/notification_provider.dart';
import 'package:kayaone/state/location_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kayaone/state/cart_provider.dart';
import 'package:kayaone/presentation/home/widgets/advertisement_carousel.dart';
import 'package:kayaone/presentation/home/widgets/consultation_card.dart';
import 'package:kayaone/presentation/home/widgets/kayark_section.dart';
import 'package:kayaone/core/utils/whatsapp_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const MyAppointmentsScreen(), // Care -> Bookings
    const DoctorListingScreen(isMainTab: true), // Doctor -> Doctor Page
    const HealthKarmaScreen(),
    const ProfileScreen(isMainTab: true),
  ];

  void setIndex(int index) {
    if ([1, 2, 3].contains(index)) {
      handleGuestRestriction(() {
        setState(() => _currentIndex = index);
      });
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _onTap(int index) {
    setIndex(index);
  }

  Future<void> handleGuestRestriction(VoidCallback action) async {
    var appLocalizations = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            appLocalizations?.translate('login_required') ?? "Login Required",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            appLocalizations?.translate('login_access_feature') ??
                "Please login to access this feature.",
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                authProvider.logout(); // Reset guest state
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.darkBlue,
              ),
              child: const Text("Login"),
            ),
          ],
        ),
      );
    } else {
      action();
    }
  }

  Widget _buildActiveIcon(IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(height: 6),
        Icon(icon, size: 26),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10), // Increase height visually
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
              selectedItemColor: AppTheme.primaryGreen,
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              showUnselectedLabels: true,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                height: 1.5,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.5,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 9), // Align unslected
                    child: Icon(Icons.home_outlined),
                  ),
                  activeIcon: _buildActiveIcon(Icons.home_rounded),
                  label: appLocalizations?.translate('nav_home') ?? "Home",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(Icons.healing_outlined),
                  ),
                  activeIcon: _buildActiveIcon(Icons.healing_rounded),
                  label: appLocalizations?.translate('nav_care') ?? "Care",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(Icons.receipt_long_outlined),
                  ),
                  activeIcon: _buildActiveIcon(Icons.receipt_long_rounded),
                  label: appLocalizations?.translate('nav_doctor') ?? "Doctor",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(Icons.favorite_border_rounded),
                  ),
                  activeIcon: _buildActiveIcon(Icons.favorite_rounded),
                  label: appLocalizations?.translate('nav_healthkarma') ??
                      "HealthKarma",
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 9),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  activeIcon: _buildActiveIcon(Icons.person_rounded),
                  label:
                      appLocalizations?.translate('nav_profile') ?? "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Sliders Controllers and Timers
  late final PageController _servicesPageController;
  late final PageController _quickActionsPageController;
  late final PageController _articlesPageController;

  int _currentServicePage = 200; // Large initial index for infinite scroll

  // Bookings Data
  List<dynamic> _recentBookings = [];

  // Auto Scroll Timer
  Timer? _serviceSliderTimer;

  @override
  void initState() {
    super.initState();
    // Initialize Notifications (Requests permission if needed)
    NotificationService().initialize(
      onNotificationReceived: (title, body) {
        if (mounted) {
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).addNotification(title, body);
        }
      },
    );

    _startServiceSliderTimer();

    // Initialize Slider Controllers with large initial page
    _servicesPageController = PageController(
      viewportFraction: 0.9,
      initialPage: _currentServicePage,
    );
    _quickActionsPageController = PageController(viewportFraction: 0.88);
    _articlesPageController = PageController(viewportFraction: 0.88);

    _fetchRecentBookings();
    _checkFirstTimeAndSmartPopups();
  }

  // --- Smart Popup Logic ---
  Timer? _smartPopupTimer;

  Future<void> _checkFirstTimeAndSmartPopups() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. First Time Video
    final bool hasSeenIntro = prefs.getBool('has_seen_intro_video') ?? false;
    if (!hasSeenIntro) {
      if (mounted) _showVideoIntro(prefs);
    } else {
      // 2. Check Kayark Banner (Every 4 hours)
      _checkAndShowKayarkBanner(prefs);
    }
  }

  void _showVideoIntro(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _VideoPopup(
        onClose: () {
          prefs.setBool('has_seen_intro_video', true);
          Navigator.pop(ctx);
          // Check Kayark Banner after video
          _checkAndShowKayarkBanner(prefs);
        },
      ),
    );
  }

  // --- KAYARK BANNER LOGIC ---
  Future<void> _checkAndShowKayarkBanner(SharedPreferences prefs) async {
    if (!mounted) return;

    final int lastKayarkTime = prefs.getInt('last_kayark_time') ?? 0;
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    // 4 Hours Interval = 4 * 60 * 60 * 1000 = 14,400,000 ms
    const int kayarkIntervalMs = 4 * 60 * 60 * 1000;

    // Show if enough time has passed (or first time)
    if (currentTime - lastKayarkTime > kayarkIntervalMs) {
      // Small delay to ensure UI is ready
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _showKayarkVerticalBanner(prefs);
      }
    }
  }

  void _showKayarkVerticalBanner(SharedPreferences prefs) {
    if (!mounted) return;

    final List<String> verticalBanners = [
      'assets/kayark/banners-vertical/banner_2026-01-07_12.37.02_.jpeg',
      'assets/kayark/banners-vertical/banner_2026-01-07_12.37.03_.jpeg',
      'assets/kayark/banners-vertical/banner_2026-01-07_12.37.05_.jpeg',
      'assets/kayark/banners-vertical/banner_2026-01-07_12.37.06_.jpeg',
    ];

    // Pick a random banner
    final String bannerImage =
        verticalBanners[Random().nextInt(verticalBanners.length)];

    showDialog(
      context: context,
      barrierDismissible: true, // Allow clicking outside
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image
                Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(bannerImage, fit: BoxFit.contain),
                  ),
                ),
                // Close Button
                Positioned(
                  top: -15,
                  right: -15,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    ).then((_) {
      // Update time only after closing or showing
      prefs.setInt('last_kayark_time', DateTime.now().millisecondsSinceEpoch);
    });
  }

  void _showLocationSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('select_delivery_location') ??
                        "Select Delivery Location",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                          context,
                        )?.translate('enter_pincode') ??
                        "Enter pin code",
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        // TODO: Implement Pin Code Logic
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)?.translate('apply') ??
                            "Apply",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[200])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)?.translate('or') ?? "Or",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[200])),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF4B6309,
                    ), // Olive Green from Image
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('add_new_address') ??
                        "Add New Address",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchRecentBookings() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId != null) {
      final bookingService = BookingService();
      final bookings = await bookingService.getUserBookings(
        authProvider.userId!,
      );

      if (mounted) {
        if (bookings != null && bookings.isNotEmpty) {
          // Sort by date descending
          bookings.sort((a, b) {
            final da = a['date']?.toString() ?? '';
            final db = b['date']?.toString() ?? '';
            return db.compareTo(da); // Descending
          });

          // Take only the first one (latest)
          setState(() {
            _recentBookings = [bookings.first];
          });
        } else {
          setState(() {
            _recentBookings = [];
          });
        }
      }
    } else {
      // No auth logic needed
    }
  }

  void _startServiceSliderTimer() {
    _serviceSliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_servicesPageController.hasClients) {
        _servicesPageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _smartPopupTimer?.cancel();

    _servicesPageController.dispose();
    _quickActionsPageController.dispose();
    _articlesPageController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    var appLocalizations = AppLocalizations.of(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by Container
      extendBody: true,
      drawer: const HomeDrawer(),
      floatingActionButton: _buildFloatingCallButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5), // Fallback
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async {
            await _fetchRecentBookings();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1️⃣ TOP HEADER + CARD 1 MERGED
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER SECTION ---
                        // Row 1: Menu | Welcome | Notification
                        Row(
                          children: [
                            Builder(
                              builder: (context) => GestureDetector(
                                onTap: () => Scaffold.of(context).openDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: AppTheme.darkBlue,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "${appLocalizations?.translate('welcome') ?? 'Welcome'},",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "$firstName 👋",
                                    style: GoogleFonts.outfit(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen(),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.darkBlue,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Row 2: Search Bar
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductListingScreen(),
                            ),
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFFB0BEC5),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    appLocalizations?.translate(
                                          'search_healthcare_prod',
                                        ) ??
                                        "Search healthcare products",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.mic_none_rounded,
                                  color: AppTheme.primaryGreen,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- LOCATION ROW ---
                        GestureDetector(
                          onTap: () => _showLocationSelectionModal(context),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Consumer<LocationProvider>(
                                builder: (context, locationProvider, child) {
                                  return Text(
                                    locationProvider.currentAddress,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.darkBlue,
                                    ),
                                  );
                                },
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppTheme.darkBlue,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 16),

                        // --- CARD 1 CONTENT (Bookings, Services, Featured) ---
                        // My Bookings
                        _buildMyBookingsSection(),

                        // Primary Services
                        _buildSectionHeader(
                          appLocalizations?.translate('our_services') ??
                              "Our Services",
                          isFirst: false,
                        ),
                        _buildPrimaryServicesSection(),

                        const SizedBox(height: 24),

                        // Featured Highlights (Now Exclusive Offers)
                        _buildSectionHeader(
                          appLocalizations?.translate('exclusive_offers') ??
                              "Exclusive Offers",
                        ),
                        // _buildFeaturedBannerSlider(),
                        const AdvertisementCarousel(), // New Widget
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 3️⃣ HEALTH KARMA (Standalone)
              SliverToBoxAdapter(child: _buildHealthKarmaSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 3.5 KAYARK SECTION
              const SliverToBoxAdapter(child: KayarkSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 3.6 CONSULTATION CARD
              SliverToBoxAdapter(
                child: ConsultationCard(
                  onTap: () => HomeScreenState.of(context)?.setIndex(1),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // 4️⃣ CARD 2: QUICK ACTIONS & CONTENT
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Quick Actions
                      _buildSectionHeader(
                        appLocalizations?.translate('quick_actions') ??
                            "Quick Actions",
                        isFirst: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildQuickActionsGrid(),
                      ),

                      const SizedBox(height: 32),

                      // Products
                      _buildSectionHeader(
                        appLocalizations?.translate('todays_top_picks') ??
                            "Today's Top Picks",
                      ),
                      _buildProductsPreview(),

                      const SizedBox(height: 24),
                      const SizedBox(height: 24),

                      // // AI Assistant
                      // _buildSectionHeader(
                      //   appLocalizations?.translate('ai_health_assistant') ??
                      //       "AI Health Assistant",
                      // ),
                      // _buildAIAssistantPromo(),
                      const SizedBox(height: 32),

                      // Articles
                      _buildSectionHeader(
                        appLocalizations?.translate('health_insights') ??
                            "Health Insights",
                      ),
                      _buildArticlesSection(),
                      const SizedBox(height: 32),

                      // Trust & Safety
                      _buildSectionHeader(
                        appLocalizations?.translate('quality_trust') ??
                            "Quality & Trust",
                      ),
                      _buildTrustSafetySection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  // Guest restriction logic moved to HomeScreenState

  // ==================== 1.5️⃣ MY BOOKINGS ====================
  // ==================== 1.5️⃣ MY BOOKINGS / PERSONALISED CARE ====================
  Widget _buildMyBookingsSection() {
    // Replaced "Last Visit" dynamic section with static "Personalised Care" card
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(children: [_buildSingleBookingCard(null)]),
    );
  }

  Widget _buildSingleBookingCard(dynamic booking) {
    var appLocalizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => HomeScreenState.of(context)?.setIndex(2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // LEFT SIDE: Text and Button
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLocalizations?.translate('your_health_priority') ??
                        "Your Health,\nOur Priority",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.darkBlue,
                      height: 1.2,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    appLocalizations?.translate('expert_care_desc') ??
                        "Expert care and guidance for a healthier you.",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => HomeScreenState.of(context)?.setIndex(2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF556B2F), // Olive Green
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                      child: Text(
                        appLocalizations?.translate('get_started') ??
                            "Get Started",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(),
                ],
              ),
            ),

            // RIGHT SIDE: Image with Circle
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    // Green Circle Ring
                    Positioned(
                      right: 0,
                      child: Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF9E9D24).withOpacity(0.5),
                            width: 6,
                          ),
                        ),
                      ),
                    ),
                    // Image
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Image.asset(
                        'assets/images/priyanka.png',
                        fit: BoxFit.contain,
                        height: 150,
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

  // ==================== 2️⃣ PRIMARY SERVICES ====================
  Widget _buildPrimaryServicesSection() {
    var appLocalizations = AppLocalizations.of(context);
    final services = [
      _ServiceCardData(
        title: appLocalizations?.translate('service_blood_collection') ??
            "Blood Collection\nat Doorstep",
        lottie: "assets/lottie/gps_navigation.json",
        image: "assets/images/services/blood collection.png",
        gradient: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
        onTap: () {
          HomeScreenState.of(context)?.handleGuestRestriction(() async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrescriptionUploadScreen(),
              ),
            );
            _fetchRecentBookings();
          });
        },
      ),
      _ServiceCardData(
        title: appLocalizations?.translate('service_doctor') ??
            "Doctor\nConsultancy",
        lottie: "assets/lottie/booking_calendar.json",
        image: "assets/images/services/Doctor Appointment.png",
        gradient: [const Color(0xFF004D40), const Color(0xFF00897B)],
        onTap: () => HomeScreenState.of(context)?.handleGuestRestriction(
          () => HomeScreenState.of(context)?.setIndex(2),
        ),
      ),
      _ServiceCardData(
        title: appLocalizations?.translate('service_products') ??
            "Healthcare\nProducts",
        lottie: "assets/lottie/upload.json",
        image: "assets/images/services/Products.png",
        gradient: [const Color(0xFF3E2723), const Color(0xFF6D4C41)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListingScreen()),
        ),
      ),
      _ServiceCardData(
        title: appLocalizations?.translate('service_healthkarma') ??
            "HealthKarma\nScore",
        lottie: "assets/lottie/Health.json",
        image: "assets/images/services/HealthKarama.png",
        gradient: [const Color(0xFF311B92), const Color(0xFF512DA8)],
        onTap: () => HomeScreenState.of(context)?.setIndex(3),
      ),
    ];

    return SizedBox(
      height: 300, // Increased height to prevent overflow village vishwakarma
      child: PageView.builder(
        controller: _servicesPageController,
        onPageChanged: (index) => _currentServicePage = index,
        itemBuilder: (context, index) {
          final service = services[index % services.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _PrimaryServiceBanner(data: service),
          )
              .animate(delay: (100 * (index % services.length)).ms)
              .fadeIn()
              .slideX(begin: 0.1);
        },
      ),
    );
  }

  // ==================== 4️⃣ HEALTHKARMA SECTION ====================
  Widget _buildHealthKarmaSection() {
    return Consumer<HealthKarmaProvider>(
      builder: (context, provider, child) {
        final result = provider.result;
        final int score = result?.score ?? 0;
        var appLocalizations = AppLocalizations.of(context);

        final String status;
        final String buttonText;
        final VoidCallback onButtonPressed;
        final String subText;

        if (result == null) {
          status = appLocalizations?.translate('hk_start_assessment') ??
              "Start Assessment";
          buttonText = appLocalizations?.translate('hk_start') ?? "Start";
          subText = appLocalizations?.translate('hk_quiz_prompt') ??
              "Take the quiz to get your score.";
          onButtonPressed = () {
            HomeScreenState.of(context)?.handleGuestRestriction(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HealthKarmaScreen()),
              );
            });
          };
        } else {
          status = score >= 80
              ? (appLocalizations?.translate('hk_excellent') ?? "Excellent")
              : score >= 60
                  ? (appLocalizations?.translate('hk_good') ?? "Good")
                  : (appLocalizations?.translate('hk_needs_attention') ??
                      "Needs Attention");
          buttonText = appLocalizations?.translate('hk_view_report') ??
              "View Detailed Report";
          subText = appLocalizations?.translate('hk_great_job') ??
              "You're doing great! Keep up the daily goals.";
          onButtonPressed = () {
            // Navigate to HealthKarma Screen (Results)
            HomeScreenState.of(context)?.setIndex(3);
          };
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.darkBlue, AppTheme.mediumBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.darkBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                children: [
                  // Background visual (Circles)
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentGreen.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 340;
                      return Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 28),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appLocalizations?.translate(
                                              'hk_your_score',
                                            ) ??
                                            "Your HealthKarma",
                                        style: GoogleFonts.outfit(
                                          fontSize: isSmallScreen ? 18 : 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        appLocalizations?.translate(
                                              'hk_ai_insights',
                                            ) ??
                                            "AI-powered personal insights",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmallScreen ? 11 : 13,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: AppTheme.primaryGreen,
                                    size: isSmallScreen ? 20 : 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            Row(
                              children: [
                                // Score Circle
                                Container(
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 60 : 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryGreen,
                                      width: 6,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "$score",
                                      style: GoogleFonts.outfit(
                                        fontSize: isSmallScreen ? 20 : 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status,
                                        style: GoogleFonts.outfit(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryGreen,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        subText,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isSmallScreen ? 11 : 12,
                                          color: Colors.white.withValues(
                                            alpha: 0.8,
                                          ),
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: onButtonPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: AppTheme.darkBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  buttonText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== 5️⃣ QUICK ACTIONS ====================
  // ==================== 5️⃣ BENTO QUICK ACTIONS ====================
  Widget _buildQuickActionsGrid() {
    var appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Column(
        children: [
          // ROW 1
          Row(
            children: [
              Expanded(
                child: _QuickActionBentoCard(
                  title: appLocalizations?.translate('qa_book_expert') ??
                      "Book\nExpert",
                  subtitle: appLocalizations?.translate('qa_consultation') ??
                      "Consultation",
                  icon: Icons.personal_injury_outlined,
                  gradient: const [Color(0xFF2E3192), Color(0xFF1BFFFF)],
                  height: 180,
                  onTap: () => HomeScreenState.of(context)?.setIndex(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionBentoCard(
                  title: appLocalizations?.translate('qa_lab_tests') ??
                      "Lab\nTests",
                  subtitle: appLocalizations?.translate('qa_home_collect') ??
                      "Home Collect",
                  icon: Icons.science_outlined,
                  gradient: const [Color(0xFFD4145A), Color(0xFFFBB03B)],
                  height: 180,
                  onTap: () {
                    HomeScreenState.of(context)?.handleGuestRestriction(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyAppointmentsScreen(
                            filterType: AppointmentType.lab,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ROW 2
          Row(
            children: [
              Expanded(
                child: _QuickActionBentoCard(
                  title: appLocalizations?.translate('qa_order_meds') ??
                      "Order\nMeds",
                  subtitle:
                      appLocalizations?.translate('qa_delivery') ?? "Delivery",
                  icon: Icons.medication_liquid_outlined,
                  gradient: const [Color(0xFF009245), Color(0xFFFCEE21)],
                  height: 180,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionBentoCard(
                  title: appLocalizations?.translate('qa_ai_analysis') ??
                      "AI\nAnalysis",
                  subtitle:
                      appLocalizations?.translate('qa_insights') ?? "Insights",
                  icon: Icons.analytics_outlined,
                  gradient: const [Color(0xFF662D8C), Color(0xFFED1E79)],
                  height: 180,
                  onTap: () => HomeScreenState.of(context)?.setIndex(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== 6️⃣ PRODUCTS PREVIEW ====================
  // ==================== 6️⃣ TOP PICKS ====================

  Widget _buildProductsPreview() {
    var appLocalizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _buildSectionHeader("Top Picks for You"),
        SizedBox(
          height: 430, // Increased height to prevent overflow (was 380)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              width: 240, // Wider card
              margin: const EdgeInsets.only(right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image & Rating Badge Stack
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/med_product_${index + 1}.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Rating Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "4.${8 - index} | 1.${index + 2}k",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Product Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            "Multivitamin",
                            "Thermometer",
                            "Omega-3",
                            "First Aid Kit",
                            "Face Masks",
                            "BP Monitor",
                          ][index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "₹599",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹799",
                              style: GoogleFonts.plusJakartaSans(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "25% OFF",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // "Earn coins" badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                size: 10,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "EARN 65 coins",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // "Get it tomorrow" text
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            "🚚 ${appLocalizations?.translate('product_get_tomorrow') ?? "Get it tomorrow"}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF536130),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Buttons Row
                        Row(
                          children: [
                            // Cart Icon Button
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF536130),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 18,
                                  color: Color(0xFF536130),
                                ),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Buy Now Button
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF4A5928,
                                    ), // Dark Green like image
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    appLocalizations?.translate('buy_now') ??
                                        "Buy Now",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 7️⃣ AI ASSISTANT PROMO ====================
  // Widget _buildAIAssistantPromo() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 24),
  //     child: Container(
  //       height: 210,
  //       decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(32),
  //         boxShadow: [
  //           BoxShadow(
  //             color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
  //             blurRadius: 20,
  //             offset: const Offset(0, 10),
  //           ),
  //         ],
  //       ),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(32),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             final isSmallScreen = constraints.maxWidth < 340;
  //             return Stack(
  //               children: [
  //                 Positioned(
  //                   right: isSmallScreen ? -50 : 4,
  //                   top: -20,
  //                   bottom: -20,
  //                   child: Opacity(
  //                     opacity: isSmallScreen ? 0.3 : 1.0,
  //                     child: Image.asset(
  //                       'assets/images/ai_assistant_visual.png',
  //                       width: isSmallScreen ? 180 : 250,
  //                       fit: BoxFit.contain,
  //                     ),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.all(28),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Text(
  //                         "Ask kayaone AI",
  //                         style: GoogleFonts.outfit(
  //                           fontSize: 24,
  //                           fontWeight: FontWeight.w800,
  //                           color: Colors.white,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Text(
  //                         "Get instant health\nguidance 24/7",
  //                         style: GoogleFonts.plusJakartaSans(
  //                           fontSize: 14,
  //                           color: Colors.white.withValues(alpha: 0.9),
  //                           height: 1.2,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       SizedBox(
  //                         width: 120,
  //                         child: ElevatedButton(
  //                           onPressed: () => Navigator.push(
  //                             context,
  //                             MaterialPageRoute(
  //                               builder: (_) => const AiAssistantScreen(),
  //                             ),
  //                           ),
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: Colors.white,
  //                             foregroundColor: const Color(0xFF00BCD4),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 16,
  //                               vertical: 0,
  //                             ),
  //                           ),
  //                           child: const Text(
  //                             "Start Chat",
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.w800,
  //                               fontSize: 13,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ==================== 8️⃣ ARTICLES SECTION ====================
  Widget _buildArticlesSection() {
    var appLocalizations = AppLocalizations.of(context);
    final articles = [
      _ArticleData(
        title: appLocalizations?.translate('art_nutrition_title') ??
            "Nutrition Guide",
        subtitle: appLocalizations?.translate('art_nutrition_sub') ??
            "Balanced diet secrets",
        image: "assets/images/article_nutrition.png",
        color: Colors.green,
      ),
      _ArticleData(
        title: appLocalizations?.translate('art_mental_title') ??
            "Mental Wellness",
        subtitle: appLocalizations?.translate('art_mental_sub') ??
            "Yoga & mindfulness",
        image: "assets/images/article_mental_health.png",
        color: Colors.indigo,
      ),
      _ArticleData(
        title:
            appLocalizations?.translate('art_sleep_title') ?? "Sleep Hygiene",
        subtitle: appLocalizations?.translate('art_sleep_sub') ??
            "The science of rest",
        image: "assets/images/article_sleep.png",
        color: Colors.blueGrey,
      ),
      _ArticleData(
        title: appLocalizations?.translate('art_heart_title') ?? "Heart Health",
        subtitle: appLocalizations?.translate('art_heart_sub') ??
            "Cardio tips for you",
        image: "assets/images/article_nutrition.png", // Reusing image for demo
        color: Colors.redAccent,
      ),
      _ArticleData(
        title: appLocalizations?.translate('art_digital_detox_title') ??
            "Digital Detox",
        subtitle: appLocalizations?.translate('art_digital_detox_sub') ??
            "Unplug to recharge",
        image:
            "assets/images/article_mental_health.png", // Reusing image for demo
        color: Colors.teal,
      ),
      _ArticleData(
        title: appLocalizations?.translate('art_immunity_title') ??
            "Immunity Boost",
        subtitle: appLocalizations?.translate('art_immunity_sub') ??
            "Stay strong & healthy",
        image: "assets/images/article_nutrition.png", // Reusing image for demo
        color: Colors.orange,
      ),
    ];

    return SizedBox(
      height: 280, // Matches other slider heights approximately
      child: PageView.builder(
        controller: _articlesPageController,
        padEnds: false,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final article = articles[index % articles.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              margin: const EdgeInsets.only(right: 0), // Handled by padding
              decoration: BoxDecoration(
                color: article.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: article.color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.asset(
                        article.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appLocalizations?.translate('featured_tag') ??
                              'FEATURED',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: article.color,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.darkBlue.withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== 9️⃣ TRUST & SAFETY ====================
  Widget _buildTrustSafetySection() {
    var appLocalizations = AppLocalizations.of(context);
    final items = [
      _TrustItem(
        Icons.verified_user,
        appLocalizations?.translate('trust_phlebotomists') ??
            "Trained Phlebotomists",
      ),
      _TrustItem(
        Icons.cleaning_services,
        appLocalizations?.translate('trust_equipment') ?? "Sterile Equipment",
      ),
      _TrustItem(
        Icons.access_time,
        appLocalizations?.translate('trust_on_time') ?? "On-Time Collection",
      ),
      _TrustItem(
        Icons.shield,
        appLocalizations?.translate('trust_secure_reports') ?? "Secure Reports",
      ),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: items
              .map<Widget>(
                (item) => SizedBox(
                  width: 75,
                  child: Column(
                    children: [
                      Icon(
                        item.icon,
                        size: 36,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.text,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(end: const Offset(1, 1)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ==================== FAB & BOTTOM NAV ====================
  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, isFirst ? 0 : 16, 24, 16),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCallButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // GestureDetector(
        //   onTap: () => Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
        //   ),
        //   child: Container(
        //     height: 120, // Slightly larger for better visibility
        //     width: 120,
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withValues(alpha: 0.1),
        //           blurRadius: 15,
        //           offset: const Offset(0, 5),
        //         ),
        //       ],
        //     ),
        //     child: Lottie.asset(
        //       'assets/lottie/robot_hello.json',
        //       fit: BoxFit.contain,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 0),
        GestureDetector(
          onTap: () => WhatsAppHelper.launchWhatsApp(
            message: "Hi, I need support with KayaOne app.",
          ),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF25D366), // WhatsApp Green
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.whatsapp,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    ).animate().scale(
          delay: 600.ms,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
        );
  }

  // Removed unused _buildBottomNav
}

// ==================== SUPPORTING DATA CLASSES & WIDGETS ====================

class _ServiceCardData {
  final String title;
  final String lottie;
  final String image;
  final List<Color> gradient;
  final VoidCallback onTap;

  _ServiceCardData({
    required this.title,
    required this.lottie,
    required this.image,
    required this.gradient,
    required this.onTap,
  });
}

class _PrimaryServiceBanner extends StatelessWidget {
  final _ServiceCardData data;

  const _PrimaryServiceBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        height: 180, // Slightly taller
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
            image: AssetImage(data.image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Black Overlay (The "Drop")
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
              ),

              // 2. Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Premium Healthcare",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 130, // Responsive width
                      child: ElevatedButton(
                        onPressed: data.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Explore Now",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionBentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? image;
  final List<Color> gradient;
  final double height;
  final VoidCallback onTap;
  final bool isHorizontal;

  const _QuickActionBentoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.height,
    required this.onTap,
    this.image,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Background Image (Subtle)
              if (image != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(image!, fit: BoxFit.cover),
                  ),
                ),

              // 2. Decorative Circles (Glass effect)
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: isHorizontal
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildIconBox(),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextContent()),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIconBox(),
                          const Spacer(),
                          _buildTextContent(),
                        ],
                      ),
              ),

              // 4. Tap Overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    splashColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildIconBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
              0.2,
            ), // Correct opacity method if needed or use withValues
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: isHorizontal ? 18 : 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TrustItem {
  final IconData icon;
  final String text;

  _TrustItem(this.icon, this.text);
}

class _ArticleData {
  final String title;
  final String subtitle;
  final String image;
  final Color color;

  _ArticleData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.color,
  });
}

class _VideoPopup extends StatefulWidget {
  final VoidCallback onClose;

  const _VideoPopup({required this.onClose});

  @override
  State<_VideoPopup> createState() => _VideoPopupState();
}

class _VideoPopupState extends State<_VideoPopup> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
          _controller.setLooping(false);
          _setupVideoListener();
        });
      });
  }

  bool _isClosing = false;

  void _setupVideoListener() {
    _controller.addListener(() {
      if (!_isClosing &&
          _controller.value.isInitialized &&
          !_controller.value.isPlaying &&
          _controller.value.position >= _controller.value.duration) {
        _isClosing = true;
        if (mounted) widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Container
          Container(
            constraints: const BoxConstraints(maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio > 0
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: _isInitialized
                  ? VideoPlayer(_controller)
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),

          // Close Button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),

          // Bottom Action
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: EdgeInsets.zero,
                  shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "Get Started",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.elasticOut).fadeIn(),
    );
  }
}

class HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final VoidCallback onMenuTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;

  HomeHeaderDelegate({
    required this.expandedHeight,
    required this.onMenuTap,
    required this.onCartTap,
    required this.onProfileTap,
    required this.onSearchTap,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = shrinkOffset / maxExtent;
    final isCollapsed = progress > 0.5;

    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName.split(' ').first;
    var appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08 * progress),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. EXPANDED CONTENT (Opacity fades out)
          Opacity(
            opacity: (1 - progress * 1.5).clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Menu | Welcome | Notification
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onMenuTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: AppTheme.darkBlue,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${appLocalizations?.translate('welcome') ?? 'Welcome'},",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              "$firstName 👋",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Consumer<NotificationProvider>(
                            builder: (context, provider, child) {
                              return Badge(
                                isLabelVisible: provider.unreadCount > 0,
                                label: Text('${provider.unreadCount}'),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.darkBlue,
                                  size: 20,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // LOCATION ROW
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppTheme.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Consumer<LocationProvider>(
                          builder: (context, locationProv, child) {
                            return Text(
                              locationProv.isLoading
                                  ? "Fetching location..."
                                  : locationProv.currentAddress,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkBlue,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // SEARCH BAR
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Search healthcare products",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. COLLAPSED CONTENT (Opacity fades in)
          // Layout: Menu | Search (Small) | Cart | Profile
          Opacity(
            opacity: (progress - 0.5 < 0 ? 0.0 : (progress - 0.5) * 2).clamp(
              0.0,
              1.0,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 10,
                20,
                10,
              ),
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Menu
                  GestureDetector(
                    onTap: onMenuTap,
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppTheme.darkBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Search (Expanded)
                  Expanded(
                    child: GestureDetector(
                      onTap: onSearchTap,
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA), // Light grey bg
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Search...", // Placeholder
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Cart
                  GestureDetector(
                    onTap: onCartTap,
                    child: Consumer<CartProvider>(
                      builder: (context, provider, child) {
                        return Badge(
                          isLabelVisible: provider.itemCount > 0,
                          label: Text('${provider.itemCount}'),
                          smallSize: 8,
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: AppTheme.darkBlue,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Profile
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryGreen,
                          width: 1.5,
                        ),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/user_avatar.png',
                          ), // Fallback or provider
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Fallback logic if image fails or uses text
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(
                          'assets/images/user_avatar.png',
                        ),
                        onBackgroundImageError: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 40; // Approx 96

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
