import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/data/services/notification_service.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

import 'package:kayaone/presentation/home/ai_assistant_screen.dart';
import 'package:kayaone/presentation/home/notifications_screen.dart';
import 'package:kayaone/presentation/home/widgets/home_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'package:kayaone/presentation/profile/profile_screen.dart';
import 'package:kayaone/presentation/prescription/prescription_upload_screen.dart';
import 'package:kayaone/presentation/booking/my_appointments_screen.dart';
import 'package:kayaone/presentation/healthkarma/health_karma_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kayaone/presentation/marketplace/product_listing_screen.dart';
import 'package:kayaone/presentation/auth/login_screen.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/state/health_karma_provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/data/services/booking_service.dart';

import 'package:kayaone/state/notification_provider.dart';
import 'package:kayaone/state/location_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kayaone/state/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();

  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  // Pages are recreated on switch, ensuring data refresh
  final List<Widget> _pages = [
    const HomeView(),
    const MyAppointmentsScreen(
      key: ValueKey('care_tab'),
      filterType: AppointmentType.lab,
      isEmbedded: true,
    ), // "Care" Tab = Lab
    const MyAppointmentsScreen(
      key: ValueKey('doctor_tab'),
      filterType: AppointmentType.doctor,
      isEmbedded: true,
    ), // "Doctor" Tab = Doctor
    const HealthKarmaScreen(),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
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
          selectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: appLocalizations?.translate('nav_home') ?? "Home",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.healing_rounded),
              label: appLocalizations?.translate('nav_care') ?? "Care",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: appLocalizations?.translate('nav_doctor') ?? "Doctor",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_rounded),
              label: appLocalizations?.translate('nav_healthkarma') ??
                  "HealthKarma",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: appLocalizations?.translate('nav_profile') ?? "Profile",
            ),
          ],
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
  late final PageController _featuredPageController;
  late final PageController _quickActionsPageController;
  late final PageController _articlesPageController;

  int _currentServicePage = 200; // Large initial index for infinite scroll
  int _currentFeaturedPage = 200;

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
    _featuredPageController = PageController(
      viewportFraction: 0.88,
      initialPage: _currentFeaturedPage,
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
      // 2. Start Random Popup Timer (checks every 2 minutes, shows rarely)
      _smartPopupTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _tryShowRandomPopup(prefs);
      });
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
          // Start smart timer after video
          _smartPopupTimer =
              Timer.periodic(const Duration(minutes: 2), (timer) {
            _tryShowRandomPopup(prefs);
          });
        },
      ),
    );
  }

  Future<void> _tryShowRandomPopup(SharedPreferences prefs) async {
    if (!mounted) return;

    final int lastPopupTime = prefs.getInt('last_popup_time') ?? 0;
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    // Minimum 10 minutes between popups to not annoy user
    const int minIntervalMs = 10 * 60 * 1000;

    if (currentTime - lastPopupTime > minIntervalMs) {
      // 30% chance to show a popup if interval passed
      if (Random().nextDouble() < 0.3) {
        _showRandomNudge(prefs);
      }
    }
  }

  void _showRandomNudge(SharedPreferences prefs) {
    final type = Random().nextInt(3); // 0: Guide, 1: Product, 2: Booking

    Widget dialog;
    switch (type) {
      case 0:
        dialog = _buildSmartDialog(
          title: "Quick App Guide 💡",
          content:
              "Did you know? You can upload prescriptions directly for faster booking!",
          lottiePath: 'assets/lottie/welcome.json',
          color: Colors.amber,
          btnText: "Got it",
          onBtn: () => Navigator.pop(context),
        );
        break;
      case 1:
        dialog = _buildSmartDialog(
          title: "New Health Products 💊",
          content:
              "Check out our latest wellness essentials. Boost your immunity today!",
          lottiePath: 'assets/lottie/Health.json',
          color: Colors.blue,
          btnText: "Explore",
          onBtn: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProductListingScreen()));
          },
        );
        break;
      case 2:
      default:
        dialog = _buildSmartDialog(
          title: "Regular Checkup? 🩺",
          content:
              "It's been a while! Schedule a full body checkup to stay on top of your health.",
          lottiePath: 'assets/lottie/booking_calendar.json',
          color: AppTheme.primaryGreen,
          btnText: "Book Now",
          onBtn: () {
            Navigator.pop(context);
            HomeScreenState.of(context)?.setIndex(1); // Care tab
          },
        );
        break;
    }

    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierColor: Colors.black.withOpacity(0.4),
    );
    prefs.setInt('last_popup_time', DateTime.now().millisecondsSinceEpoch);
  }

  Widget _buildSmartDialog({
    required String title,
    required String content,
    required String lottiePath,
    required Color color,
    required String btnText,
    required VoidCallback onBtn,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient & Lottie
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative Circle
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Lottie.asset(lottiePath, height: 130),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onBtn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: color.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        btnText,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[500],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Maybe Later",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(duration: 400.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 300.ms),
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
    _featuredPageController.dispose();
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                            GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen
                                      .withValues(alpha: 0.1),
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
                                  border:
                                      Border.all(color: Colors.grey.shade200),
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
                        Row(
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

                        // Featured Highlights
                        _buildSectionHeader(
                          appLocalizations?.translate('featured_highlights') ??
                              "Featured Highlights",
                        ),
                        _buildFeaturedBannerSlider(),
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
                      _buildComingSoonSection(),
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

  Future<void> _handleGuestRestriction(VoidCallback action) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isGuest) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Login Required",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
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

  // ==================== 1.5️⃣ MY BOOKINGS ====================
  // ==================== 1.5️⃣ MY BOOKINGS / PERSONALISED CARE ====================
  Widget _buildMyBookingsSection() {
    // Replaced "Last Visit" dynamic section with static "Personalised Care" card
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: _buildSingleBookingCard(null),
    );
  }

  Widget _buildSingleBookingCard(dynamic booking) {
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
                    "Personalised Care\nfrom Trusted Doctors",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppTheme.darkBlue,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Personalised guidance for every\nstep of your journey",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
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
                        "Consult Now",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
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
    final services = [
      _ServiceCardData(
        title: "Blood Collection\nat Doorstep",
        lottie: "assets/lottie/gps_navigation.json",
        image: "assets/images/services/blood collection.png",
        gradient: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
        onTap: () {
          _handleGuestRestriction(() async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrescriptionUploadScreen()),
            );
            _fetchRecentBookings();
          });
        },
      ),
      _ServiceCardData(
        title: "Doctor\nAppointment",
        lottie: "assets/lottie/booking_calendar.json",
        image: "assets/images/services/Doctor Appointment.png",
        gradient: [const Color(0xFF004D40), const Color(0xFF00897B)],
        onTap: () => _handleGuestRestriction(
            () => HomeScreenState.of(context)?.setIndex(2)),
      ),
      _ServiceCardData(
        title: "Healthcare\nProducts",
        lottie: "assets/lottie/upload.json",
        image: "assets/images/services/Products.png",
        gradient: [const Color(0xFF3E2723), const Color(0xFF6D4C41)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListingScreen()),
        ),
      ),
      _ServiceCardData(
        title: "HealthKarma\nScore",
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

  // ==================== 3️⃣ FEATURED BANNER SLIDER ====================
  Widget _buildFeaturedBannerSlider() {
    final banners = [
      "Safe Blood Collection at Home",
      "AI-Powered HealthKarma Score",
      "Talk to Doctors Anytime", // Placeholder title, replaced by widget
      "Smart Healthcare Products",
    ];

    return SizedBox(
      height: 300,
      child: PageView.builder(
        // itemCount removed for infinite scroll
        controller: _featuredPageController,
        onPageChanged: (index) => _currentFeaturedPage = index,
        itemBuilder: (context, index) {
          final modIndex = index % 4;

          final bannerTitle = banners[modIndex];
          // Distinct images for each banner
          String imageAsset;
          switch (modIndex) {
            case 0:
              imageAsset = 'assets/images/promo_milky_blood.png';
              break;
            case 1:
              imageAsset = 'assets/images/promo_milky_health.png';
              break;
            case 3:
              imageAsset = 'assets/images/promo_milky_pharmacy.png';
              break;
            default:
              imageAsset = 'assets/images/promo_milky_health.png';
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Dark gradient for text readability (matching Quick Actions)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Text(
                    bannerTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: 0.2);
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

        final String status;
        final String buttonText;
        final VoidCallback onButtonPressed;
        final String subText;

        if (result == null) {
          status = "Start Assessment";
          buttonText = "Start";
          subText = "Take the quiz to get your score.";
          onButtonPressed = () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthKarmaScreen()),
            );
          };
        } else {
          status = score >= 80
              ? "Excellent"
              : score >= 60
                  ? "Good"
                  : "Needs Attention";
          buttonText = "View Detailed Report";
          subText = "You're doing great! Keep up the daily goals.";
          onButtonPressed = () {
            // Navigate to HealthKarma Screen (Results)
            HomeScreenState.of(context)?.setIndex(3);
            //  OR navigate directly if the tab index isn't correct or you want a push
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HealthKarmaScreen()),
            );
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
                                        "Your HealthKarma",
                                        style: GoogleFonts.outfit(
                                          fontSize: isSmallScreen ? 18 : 22,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
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
                                    color: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
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
  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickAction(
        "Book Now",
        "Expert Consultation",
        Icons.bloodtype,
        'assets/images/quick_action_consult_real_1767126392848.png',
        [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
        () {
          _handleGuestRestriction(() async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrescriptionUploadScreen()),
            );
            _fetchRecentBookings();
          });
        },
      ),
      _QuickAction(
        "Lab Tests",
        "Home Collection",
        Icons.science,
        'assets/images/quick_action_lab_real_1767126410208.png',
        [const Color(0xFFC0392B), const Color(0xFFE74C3C)],
        () => _handleGuestRestriction(
            () => HomeScreenState.of(context)?.setIndex(2)),
      ),
      _QuickAction(
        "Medicines",
        "Fast Delivery",
        Icons.medication,
        'assets/images/quick_action_meds_real_1767126429746.png',
        [const Color(0xFF2E7D32), const Color(0xFF43A047)],
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListingScreen()),
        ),
      ),
      _QuickAction(
        "AI Analysis",
        "Smart Insights",
        Icons.analytics,
        'assets/images/quick_action_ai_real_1767126447644.png',
        [const Color(0xFF5B2C6F), const Color(0xFF8E44AD)],
        () => HomeScreenState.of(context)?.setIndex(3),
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _QuickActionPremiumCard(
          action: actions[index],
          isSmall: false,
          index: index,
        );
      },
    );
  }

  // ==================== 6️⃣ PRODUCTS PREVIEW ====================
  // ==================== 6️⃣ TOP PICKS ====================
  // ==================== 8️⃣ COMING SOON ====================
  Widget _buildComingSoonSection() {
    final comingSoonItems = [
      {
        'name': 'Grape Extract',
        'image': 'assets/images/products/coming_soon/grape.jpeg'
      },
      {
        'name': 'Kesar Gold',
        'image': 'assets/images/products/coming_soon/kesar.png'
      },
      {
        'name': 'Kojiveda',
        'image': 'assets/images/products/coming_soon/kojiveda.jpeg'
      },
      {
        'name': 'Korphad Gel',
        'image': 'assets/images/products/coming_soon/korphad.png'
      },
      {
        'name': 'Neem Oil',
        'image': 'assets/images/products/coming_soon/neem.jpeg'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Coming Soon"),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: comingSoonItems.length,
            itemBuilder: (context, index) {
              final item = comingSoonItems[index];

              // Determine background color based on index for variety
              final bgColors = [
                const Color(0xFFF3E5F5), // Purple tint
                const Color(0xFFFFF3E0), // Orange tint
                const Color(0xFFE0F7FA), // Cyan tint
                const Color(0xFFE8F5E9), // Green tint
                const Color(0xFFFCE4EC), // Pink tint
              ];
              final bgColor = bgColors[index % bgColors.length];

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background Blob/Shape
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Image.asset(
                                  item['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey.shade300,
                                      size: 40,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 32), // Space for overlay
                          ],
                        ),
                      ),
                      // "Coming Soon" Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.03),
                            border: Border(
                              top: BorderSide(
                                color: Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Coming Soon",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Product Name Overlay (Optional, enhances look)
                      Positioned(
                        bottom: 34,
                        left: 12,
                        right: 12,
                        child: Text(
                          item['name']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Tap Ripple
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            splashColor:
                                AppTheme.primaryGreen.withValues(alpha: 0.1),
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
        // Notify Me Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Notify Me When Available",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsPreview() {
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
                                color: AppTheme.primaryGreen
                                    .withValues(alpha: 0.1),
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on,
                                  size: 10, color: Colors.amber),
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
                            "🚚 Get it tomorrow",
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: const Color(0xFF536130),
                                fontWeight: FontWeight.w600),
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
                                border:
                                    Border.all(color: const Color(0xFF536130)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined,
                                    size: 18, color: Color(0xFF536130)),
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
                                        0xFF4A5928), // Dark Green like image
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
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
    final articles = [
      _ArticleData(
        title: "Nutrition Guide",
        subtitle: "Balanced diet secrets",
        image: "assets/images/article_nutrition.png",
        color: Colors.green,
      ),
      _ArticleData(
        title: "Mental Wellness",
        subtitle: "Yoga & mindfulness",
        image: "assets/images/article_mental_health.png",
        color: Colors.indigo,
      ),
      _ArticleData(
        title: "Sleep Hygiene",
        subtitle: "The science of rest",
        image: "assets/images/article_sleep.png",
        color: Colors.blueGrey,
      ),
      _ArticleData(
        title: "Heart Health",
        subtitle: "Cardio tips for you",
        image: "assets/images/article_nutrition.png", // Reusing image for demo
        color: Colors.redAccent,
      ),
      _ArticleData(
        title: "Digital Detox",
        subtitle: "Unplug to recharge",
        image:
            "assets/images/article_mental_health.png", // Reusing image for demo
        color: Colors.teal,
      ),
      _ArticleData(
        title: "Immunity Boost",
        subtitle: "Stay strong & healthy",
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
                border: Border.all(
                  color: article.color.withValues(alpha: 0.3),
                ),
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
    final items = [
      _TrustItem(Icons.verified_user, "Trained Phlebotomists"),
      _TrustItem(Icons.cleaning_services, "Sterile Equipment"),
      _TrustItem(Icons.access_time, "On-Time Collection"),
      _TrustItem(Icons.shield, "Secure Reports"),
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
                  ).animate().fadeIn(delay: 200.ms).scale(
                        end: const Offset(1, 1),
                      ),
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
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
          ),
          child: Container(
            height: 120, // Slightly larger for better visibility
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Lottie.asset(
              'assets/lottie/robot_hello.json',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 0),
        GestureDetector(
          onTap: () async {
            const String phoneNumber = "919359742537";
            final Uri whatsappAppUri =
                Uri.parse("whatsapp://send?phone=$phoneNumber");
            final Uri whatsappWebUri = Uri.parse("https://wa.me/$phoneNumber");

            try {
              if (await canLaunchUrl(whatsappAppUri)) {
                await launchUrl(whatsappAppUri,
                    mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(whatsappWebUri,
                    mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              debugPrint("Error launching WhatsApp: $e");
            }
          },
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

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final String imagePath;
  final List<Color> gradient;
  final VoidCallback onTap;

  _QuickAction(this.title, this.subtitle, this.icon, this.imagePath,
      this.gradient, this.onTap);
}

class _QuickActionPremiumCard extends StatelessWidget {
  final _QuickAction action;
  final bool isSmall;
  final int index;

  const _QuickActionPremiumCard({
    required this.action,
    required this.isSmall,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: action.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: action.gradient.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 1. Background Image with Overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.2, // Subtle background image
                  child: Image.asset(
                    action.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 2. Glassmorphism Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    // Shiny Title
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        action.title.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      action.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 4. Tap Ripple
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: action.onTap,
                    splashColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                )
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
                      child: CircularProgressIndicator(color: Colors.white)),
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
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  "Get Started",
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
                          child: const Icon(Icons.menu_rounded,
                              color: AppTheme.darkBlue, size: 20),
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
                              builder: (_) => const NotificationsScreen()),
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
                      const Icon(Icons.location_on,
                          color: AppTheme.primaryGreen, size: 16),
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
                          const Icon(Icons.search_rounded,
                              color: Colors.grey, size: 24),
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
                                )
                              ],
                            ),
                            child: const Icon(Icons.tune_rounded,
                                size: 18, color: AppTheme.darkBlue),
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
            opacity: (progress - 0.5 < 0 ? 0.0 : (progress - 0.5) * 2)
                .clamp(0.0, 1.0),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 10, 20, 10),
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Menu
                  GestureDetector(
                    onTap: onMenuTap,
                    child: const Icon(Icons.menu_rounded,
                        color: AppTheme.darkBlue, size: 24),
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
                            const Icon(Icons.search_rounded,
                                color: Colors.grey, size: 18),
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
                          child: const Icon(Icons.shopping_cart_outlined,
                              color: AppTheme.darkBlue, size: 24),
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
                            color: AppTheme.primaryGreen, width: 1.5),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/images/user_avatar.png'), // Fallback or provider
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Fallback logic if image fails or uses text
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            AssetImage('assets/images/user_avatar.png'),
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
