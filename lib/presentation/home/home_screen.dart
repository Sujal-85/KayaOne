import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:medinest/data/services/notification_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:medinest/presentation/home/ai_assistant_screen.dart';
import 'package:medinest/presentation/home/notifications_screen.dart';
import 'package:medinest/presentation/profile/profile_screen.dart';
import 'package:medinest/presentation/prescription/prescription_upload_screen.dart';
import 'package:medinest/presentation/booking/my_appointments_screen.dart';
import 'package:medinest/presentation/healthkarma/health_karma_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medinest/presentation/marketplace/product_listing_screen.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/state/health_karma_provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/data/services/booking_service.dart';
import 'package:medinest/presentation/doctors/doctor_listing_screen.dart';
import 'package:medinest/state/notification_provider.dart';

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
    _onTap(index);
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _pages = [
    const HomeView(),
    const MyAppointmentsScreen(
        filterType: AppointmentType.lab, isEmbedded: true), // "Care" Tab = Lab
    const MyAppointmentsScreen(
        filterType: AppointmentType.doctor,
        isEmbedded: true), // "Doctor" Tab = Doctor
    const HealthKarmaScreen(),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentIndex = index);
      // Ensure we switch to root when coming from another tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentIndex].currentState!.maybePop();
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(5, (index) => _buildOffstageNavigator(index)),
        ),
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
                fontWeight: FontWeight.w800, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500, fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.healing_rounded), label: "Care"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded), label: "Doctor"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded), label: "HealthKarma"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => _pages[index]);
      },
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final AnimationController _searchAnimController;
  late final Animation<double> _searchExpandAnimation;

  final FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  // Sliders Controllers and Timers
  late final PageController _servicesPageController;
  late final PageController _featuredPageController;

  int _currentServicePage = 200; // Large initial index for infinite scroll
  int _currentFeaturedPage = 200;

  // Bookings Data
  List<dynamic> _recentBookings = [];
  bool _isBookingsLoading = true;

  // Search Placeholder Animation
  final List<String> _searchKeywords = [
    "blood test",
    "specialist doctor",
    "healthcare products",
    "symptoms"
  ];
  int _currentKeywordIndex = 0;
  String _currentHint = "Search blood test";
  late final Timer _placeholderTimer;

  // Voice Search
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  // Auto Scroll Timer
  Timer? _serviceSliderTimer;

  @override
  void initState() {
    super.initState();
    // Initialize Notifications (Requests permission if needed)
    NotificationService().initialize(
      onNotificationReceived: (title, body) {
        if (mounted) {
          Provider.of<NotificationProvider>(context, listen: false)
              .addNotification(title, body);
        }
      },
    );

    _initSpeech();
    _startServiceSliderTimer();

    _searchAnimController = AnimationController(vsync: this, duration: 300.ms);
    _searchExpandAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _searchAnimController, curve: Curves.easeOutBack),
    );

    // Start cycling placeholder
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentKeywordIndex =
              (_currentKeywordIndex + 1) % _searchKeywords.length;
          _currentHint = "Search ${_searchKeywords[_currentKeywordIndex]}";
        });
      }
    });

    // Initialize Slider Controllers with large initial page
    _servicesPageController =
        PageController(viewportFraction: 0.9, initialPage: _currentServicePage);
    _featuredPageController = PageController(
        viewportFraction: 0.88, initialPage: _currentFeaturedPage);

    _fetchRecentBookings();
  }

  Future<void> _fetchRecentBookings() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userId != null) {
      final bookingService = BookingService();
      final bookings =
          await bookingService.getUserBookings(authProvider.userId!);

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
            _isBookingsLoading = false;
          });
        } else {
          setState(() {
            _recentBookings = [];
            _isBookingsLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() => _isBookingsLoading = false);
      }
    }
  }

  void _initSpeech() async {
    // Request microphone permission first
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      await Permission.microphone.request();
    }

    _speechEnabled = await _speechToText.initialize();
    setState(() {});
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

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listening...")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
      // Try initializing again
      _initSpeech();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      _searchController.text = result.recognizedWords;
      _handleSearch(result.recognizedWords);
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('doctor') || lowerQuery.contains('appointment')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoctorListingScreen()),
      );
    } else if (lowerQuery.contains('booking') ||
        lowerQuery.contains('history')) {
      HomeScreenState.of(context)?.setIndex(1); // Care Tab (Appointments)
    } else {
      // Default to Product Search
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductListingScreen(initialSearchQuery: query),
        ),
      );
    }
  }

  @override
  void dispose() {
    _placeholderTimer.cancel();
    _serviceSliderTimer?.cancel();

    _servicesPageController.dispose();
    _featuredPageController.dispose();
    _searchAnimController.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName ?? 'User';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBody: true,
      floatingActionButton: _buildFloatingCallButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          setState(() => _isBookingsLoading = true);
          await _fetchRecentBookings();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1️⃣ TOP HEADER + SEARCH
            SliverAppBar(
              pinned: true,
              expandedHeight: 160,
              automaticallyImplyLeading: false,
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _buildHeaderSection(firstName),
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                title: LayoutBuilder(builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final isCollapsed =
                      top <= 120; // Heuristic for collapsed state
                  return isCollapsed
                      ? _buildCollapsedSearch()
                      : const SizedBox.shrink();
                }),
              ),
            ),

            // 1.5️⃣ MY BOOKINGS (Dynamic)
            _buildMyBookingsSection(),

            // 2️⃣ PRIMARY SERVICES (Full-width Banners)
            SliverToBoxAdapter(
                child: _buildSectionHeader("Our Services", isFirst: true)),
            _buildPrimaryServicesSection(),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // 3️⃣ FEATURED HIGHLIGHTS
            SliverToBoxAdapter(
                child: _buildSectionHeader("Featured Highlights")),
            _buildFeaturedBannerSlider(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 4️⃣ HEALTHKARMA CORE SECTION
            SliverToBoxAdapter(
                child: _buildSectionHeader("Health Checkup Stats")),
            _buildHealthKarmaSection(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 5️⃣ QUICK ACTIONS GRID
            SliverToBoxAdapter(child: _buildSectionHeader("Quick Actions")),
            _buildQuickActionsGrid(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 6️⃣ HEALTHCARE PRODUCTS PREVIEW
            SliverToBoxAdapter(child: _buildSectionHeader("Today's Top Picks")),
            _buildProductsPreview(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 7️⃣ AI ASSISTANT PROMO CARD
            SliverToBoxAdapter(
                child: _buildSectionHeader("AI Health Assistant")),
            _buildAIAssistantPromo(),

            const SliverToBoxAdapter(child: SizedBox(height: 48)),

            // 8️⃣ HEALTH ARTICLES SECTION
            SliverToBoxAdapter(child: _buildSectionHeader("Health Insights")),
            _buildArticlesSection(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 9️⃣ TRUST & SAFETY
            SliverToBoxAdapter(child: _buildSectionHeader("Quality & Trust")),
            _buildTrustSafetySection(),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ==================== 1️⃣ HEADER ====================
  Widget _buildHeaderSection(String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 45, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, $firstName 👋",
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkBlue,
                      ),
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppTheme.primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          "Mumbai, India",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppTheme.darkBlue),
                      if (provider.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Animated Search Bar
          _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return ScaleTransition(
      scale: _searchExpandAnimation,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: _currentHint,
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
          suffixIcon: IconButton(
            icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic,
                color: _speechToText.isListening
                    ? Colors.red
                    : AppTheme.primaryGreen),
            onPressed: _startListening,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        onSubmitted: _handleSearch,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCollapsedSearch() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentHint,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 1.5️⃣ MY BOOKINGS ====================
  Widget _buildMyBookingsSection() {
    if (_isBookingsLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
          ),
        ),
      );
    }

    if (_recentBookings.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: GestureDetector(
            onTap: () => HomeScreenState.of(context)?.setIndex(2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryGreen,
                    AppTheme.primaryGreen.withValues(alpha: 0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_circle_outline,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "No Previous Bookings",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Book a consultation with top specialists",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Last Visit"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSingleBookingCard(_recentBookings.first),
          ),
        ],
      ),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services_outlined,
                  color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['patientName'] ?? "Blood Collection",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking['date'] ?? "Date",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "View",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ==================== 2️⃣ PRIMARY SERVICES ====================
  SliverToBoxAdapter _buildPrimaryServicesSection() {
    final services = [
      _ServiceCardData(
        title: "Blood Collection\nat Doorstep",
        lottie: "assets/lottie/gps_navigation.json",
        gradient: [const Color(0xFF1A237E), const Color(0xFF3949AB)],
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PrescriptionUploadScreen()));
          _fetchRecentBookings();
        },
      ),
      _ServiceCardData(
        title: "Doctor\nAppointment",
        lottie: "assets/lottie/booking_calendar.json",
        gradient: [const Color(0xFF004D40), const Color(0xFF00897B)],
        onTap: () => HomeScreenState.of(context)?.setIndex(2),
      ),
      _ServiceCardData(
        title: "Healthcare\nProducts",
        lottie: "assets/lottie/upload.json",
        gradient: [const Color(0xFF3E2723), const Color(0xFF6D4C41)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProductListingScreen())),
      ),
      _ServiceCardData(
        title: "HealthKarma\nScore",
        lottie: "assets/lottie/Health.json",
        gradient: [const Color(0xFF311B92), const Color(0xFF512DA8)],
        onTap: () => HomeScreenState.of(context)?.setIndex(3),
      ),
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200, // Increased height to prevent overflow village vishwakarma
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
      ),
    );
  }

  // ==================== 3️⃣ FEATURED BANNER SLIDER ====================
  SliverToBoxAdapter _buildFeaturedBannerSlider() {
    final banners = [
      "Safe Blood Collection at Home",
      "AI-Powered HealthKarma Score",
      "Talk to Doctors Anytime",
      "Smart Healthcare Products",
    ];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: PageView.builder(
          // itemCount removed for infinite scroll
          controller: _featuredPageController,
          onPageChanged: (index) => _currentFeaturedPage = index,
          itemBuilder: (context, index) {
            final bannerTitle = banners[index % banners.length];
            // Distinct images for each banner
            String imageAsset;
            switch (index % 4) {
              case 0:
                imageAsset = 'assets/images/promo_milky_blood.png';
                break;
              case 1:
                imageAsset = 'assets/images/promo_milky_health.png';
                break;
              case 2:
                imageAsset = 'assets/images/promo_milky_doctor.png';
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
                  // Subtle gradient for text readability if needed
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.6)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
                        color: AppTheme.darkBlue,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: 0.2);
          },
        ),
      ),
    );
  }

  // ==================== 4️⃣ HEALTHKARMA SECTION ====================
  SliverToBoxAdapter _buildHealthKarmaSection() {
    return SliverToBoxAdapter(
      child: Consumer<HealthKarmaProvider>(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.auto_awesome,
                                        color: AppTheme.primaryGreen,
                                        size: isSmallScreen ? 20 : 24),
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
                                          width: 6),
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
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
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
      ),
    );
  }

  // ==================== 5️⃣ QUICK ACTIONS ====================
  SliverToBoxAdapter _buildQuickActionsGrid() {
    final actions = [
      _QuickAction("Book Now", Icons.bloodtype, () {}),
      _QuickAction("Consult Doctor", Icons.video_call, () {}),
      _QuickAction("Buy Health Products", Icons.shopping_bag, () {}),
      _QuickAction("Talk to AI Assistant", Icons.smart_toy, () {}),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.15,
          children: actions
              .map((action) => _QuickActionCard(action: action))
              .toList(),
        ),
      ),
    );
  }

  // ==================== 6️⃣ PRODUCTS PREVIEW ====================
  SliverToBoxAdapter _buildProductsPreview() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: Image.asset(
                        'assets/images/med_product_${index + 1}.png',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
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
                                "BP Monitor"
                              ][index],
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const Text("₹799",
                              style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 11)),
                          Text("₹599",
                              style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryGreen)),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              minimumSize: const Size(double.infinity, 32),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Add to Cart",
                                style: TextStyle(fontSize: 11)),
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
      ),
    );
  }

  // ==================== 7️⃣ AI ASSISTANT PROMO ====================
  SliverToBoxAdapter _buildAIAssistantPromo() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 340;
                return Stack(
                  children: [
                    Positioned(
                      right: isSmallScreen ? -50 : -20,
                      top: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: isSmallScreen ? 0.3 : 1.0,
                        child: Image.asset(
                          'assets/images/ai_assistant_visual.png',
                          width: isSmallScreen ? 180 : 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Ask MediNest AI",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Get instant health\nguidance 24/7",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AiAssistantScreen())),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF00BCD4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                              ),
                              child: const Text("Start Chat",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 8️⃣ ARTICLES SECTION ====================
  SliverToBoxAdapter _buildArticlesSection() {
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
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(
                      image: AssetImage(article.image),
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
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: article.color.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "HEALTH",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          article.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (200 * index).ms).fadeIn().slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 9️⃣ TRUST & SAFETY ====================
  SliverToBoxAdapter _buildTrustSafetySection() {
    final items = [
      _TrustItem(Icons.verified_user, "Trained Phlebotomists"),
      _TrustItem(Icons.cleaning_services, "Sterile Equipment"),
      _TrustItem(Icons.access_time, "On-Time Collection"),
      _TrustItem(Icons.shield, "Secure Reports"),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: items
              .map<Widget>((item) => SizedBox(
                    width: 75,
                    child: Column(
                      children: [
                        Icon(item.icon, size: 36, color: AppTheme.primaryGreen),
                        const SizedBox(height: 8),
                        Text(
                          item.text,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms).scale(
                        begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ==================== FAB & BOTTOM NAV ====================
  Widget _buildSectionHeader(String title, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, isFirst ? 0 : 16, 24, 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.darkBlue,
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
            child: Lottie.asset('assets/lottie/robot_hello.json',
                fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 0),
        FloatingActionButton.extended(
          heroTag: "call_fab",
          onPressed: () async {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: '9359742537',
            );
            if (await canLaunchUrl(launchUri)) {
              await launchUrl(launchUri);
            }
          },
          backgroundColor: AppTheme.primaryGreen,
          icon: const Icon(Icons.phone),
          label: Text(
            "Call to Book",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ],
    ).animate().scale(
        delay: 600.ms, begin: const Offset(0, 0), end: const Offset(1, 1));
  }

  // Removed unused _buildBottomNav
}

// ==================== SUPPORTING DATA CLASSES & WIDGETS ====================

class _ServiceCardData {
  final String title;
  final String lottie;
  final List<Color> gradient;
  final VoidCallback onTap;

  _ServiceCardData(
      {required this.title,
      required this.lottie,
      required this.gradient,
      required this.onTap});
}

class _PrimaryServiceBanner extends StatelessWidget {
  final _ServiceCardData data;

  const _PrimaryServiceBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: data.gradient[0].withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                child: Lottie.asset(
                  data.lottie,
                  width: 130,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 110,
                      child: ElevatedButton(
                        onPressed: data.onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: data.gradient[0],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Book Now",
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
  final IconData icon;
  final VoidCallback onTap;

  _QuickAction(this.title, this.icon, this.onTap);
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 48, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text(
              action.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ],
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
