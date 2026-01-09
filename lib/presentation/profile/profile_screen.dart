import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/data/services/storage_service.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:kayaone/presentation/profile/my_bookings_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart'; // Added import
import 'package:kayaone/presentation/auth/login_screen.dart'; // Added import
import 'package:kayaone/presentation/profile/my_orders_screen.dart';
import 'package:kayaone/state/language_provider.dart'; // Added import
import 'package:kayaone/presentation/profile/help_support_screen.dart';
import 'package:kayaone/presentation/profile/rate_app_screen.dart';
import 'package:kayaone/presentation/profile/offers_screen.dart';
import 'package:kayaone/presentation/booking/my_appointments_screen.dart';
import 'package:kayaone/presentation/tracking/tracking_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.phoneNumber != null) {
      final data = await _authService.getProfile(auth.phoneNumber!);
      if (data != null) {
        auth.login(
          auth.phoneNumber!,
          userId: data['_id'],
          name: data['name'],
          email: data['email'],
          city: data['city'],
          dob: data['dob'],
          profilePic: data['profilePic'],
          isProfileComplete: data['isProfileComplete'] ?? false,
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    var appLocalizations =
        AppLocalizations.of(context); // Added for localization

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      try {
        setState(() => _isUploading = true);
        // Use phoneNumber instead of userId, as required by the backend endpoint
        final url = await _storageService.uploadProfilePic(
            auth.phoneNumber!, File(image.path));

        // Update in state locally
        auth.updateProfilePic(url!); // url is not null if no exception

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations?.translate('profile_pic_updated') ??
                "Profile picture updated!"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  // New _logout function from the provided code edit
  void _logout(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations?.translate('logout') ?? "Logout"),
        content: Text(appLocalizations?.translate('logout_confirmation') ??
            "Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appLocalizations?.translate('cancel') ?? "Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(appLocalizations?.translate('logout') ?? "Logout",
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Method to show language selector
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languageProvider =
            Provider.of<LanguageProvider>(context, listen: false);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('select_language') ??
                    "Select Language",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                title: Text("English", style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇮🇳", style: TextStyle(fontSize: 24)),
                title: Text("हिंदी (Hindi)",
                    style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text("🇮🇳", style: TextStyle(fontSize: 24)),
                title: Text("मराठी (Marathi)",
                    style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  languageProvider.changeLanguage(const Locale('mr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    var appLocalizations = AppLocalizations.of(context);

    // Using Stack to have the body overlap the header
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9), // Light grey background
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              child: Stack(
                children: [
                  // 1. Leafy Header (Transparent now, just for spacing/content)
                  _buildLeafyHeader(auth, appLocalizations),

                  // 2. Body Content (Overlapping)
                  Container(
                    margin: const EdgeInsets.only(top: 140),
                    decoration: const BoxDecoration(
                        color: Colors
                            .white, // Solid white background for clean look
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          )
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Orders (Prominent but integrated) ---
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyOrdersScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                    0xFFF1F8E9), // Light Olive/Green tint
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF4B6309)
                                        .withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Color(0xFF4B6309)),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appLocalizations
                                                ?.translate('my_orders') ??
                                            "My Orders",
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.darkBlue,
                                        ),
                                      ),
                                      Text(
                                        appLocalizations
                                                ?.translate('track_manage') ??
                                            "Track & Manage orders",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios_rounded,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 32),

                          // --- Your Information ---
                          Text(
                            appLocalizations?.translate('your_information') ??
                                "YOUR INFORMATION",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildProfileItem(
                            icon: Icons.calendar_month_outlined,
                            title: appLocalizations?.translate('my_bookings') ??
                                "My Bookings",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyBookingsScreen()));
                            },
                          ),

                          _buildProfileItem(
                            icon: Icons.medical_services_outlined,
                            title: appLocalizations
                                    ?.translate('your_consultations') ??
                                "Your Consultations",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const MyAppointmentsScreen(
                                            filterType: AppointmentType.doctor,
                                          )));
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.local_offer_outlined,
                            title: appLocalizations
                                    ?.translate('offers_discounts') ??
                                "Offers & Discounts",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const OffersScreen()));
                            },
                            isHighlight: true, // Optional: highlight offers
                          ),

                          const SizedBox(height: 32),

                          // --- Other Information ---
                          Text(
                            appLocalizations?.translate('other_information') ??
                                "OTHER INFORMATION",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileItem(
                            icon: Icons.language,
                            title: appLocalizations?.translate('language') ??
                                "Language",
                            onTap: () => _showLanguageSelector(context),
                          ),
                          _buildProfileItem(
                            icon: Icons.headset_mic_outlined,
                            title:
                                appLocalizations?.translate('help_support') ??
                                    "Help & Support",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const HelpSupportScreen()));
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.star_outline_rounded,
                            title: appLocalizations?.translate('rate_us') ??
                                "Rate Us",
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RateAppScreen()));
                            },
                          ),
                          _buildProfileItem(
                            icon: Icons.logout_rounded,
                            title: appLocalizations?.translate('logout') ??
                                "Log Out",
                            onTap: () => _logout(context),
                            isDestructive: true,
                          ),

                          const SizedBox(height: 48), // Bottom Padding
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Back Button removed (handled in header)
          ],
        ),
      ),
    );
  }

  Widget _buildLeafyHeader(
      AuthProvider auth, AppLocalizations? appLocalizations) {
    return SizedBox(
      height: 220, // Reduced height
      width: double.infinity,
      // Removed decoration: Handled by parent container
      child: Padding(
        padding: const EdgeInsets.only(
            left: 24, right: 24, top: 60), // Reduced top padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 1),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 16), // Spacing between back button and avatar
            // Profile Pic
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                backgroundImage: (auth.profilePic != null &&
                        auth.profilePic!.isNotEmpty &&
                        auth.profilePic!.startsWith('http'))
                    ? NetworkImage(auth.profilePic!)
                    : null,
                child: (auth.profilePic == null ||
                        auth.profilePic!.isEmpty ||
                        !auth.profilePic!.startsWith('http'))
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Name & Edit
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  auth.userName ??
                      (appLocalizations?.translate('guest_user') ??
                          "Guest User"),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        appLocalizations?.translate('edit_profile') ??
                            "Edit Profile",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: double.infinity, // Ensure it fills width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  Colors.grey.withOpacity(0.1)), // Added border for visibility
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08), // Increased opacity
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 28), // Darker icon
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700, // Bolder text
                color: const Color(0xFF0F3460), // Explicit Dark Blue
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDestructive ? const Color(0xFFFFEBEE) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.white
                      : (isHighlight
                          ? const Color(0xFFE0F2F1)
                          : const Color(0xFFF7F9FB)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 20,
                    color: isDestructive
                        ? Colors.red
                        : (isHighlight
                            ? AppTheme.primaryGreen
                            : Colors.grey[700])),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red : AppTheme.darkBlue,
                  ),
                ),
              ),
              if (!isDestructive)
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
