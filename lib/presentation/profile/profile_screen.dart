import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/state/language_provider.dart';
import 'package:kayaone/data/services/storage_service.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:kayaone/presentation/profile/account_info_screen.dart';
import 'package:kayaone/presentation/profile/my_bookings_screen.dart';
import 'package:kayaone/presentation/profile/profile_language_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart'; // Added import
import 'package:kayaone/presentation/auth/login_screen.dart'; // Added import

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
      setState(() => _isUploading = true);
      // Use phoneNumber instead of userId, as required by the backend endpoint
      final url = await _storageService.uploadProfilePic(
          auth.phoneNumber!, File(image.path));

      if (url != null) {
        // Update in state locally
        auth.updateProfilePic(url);

        // Backend update is already handled by uploadProfilePic (which calls /update-avatar)

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Changed to use localization
            content: Text(appLocalizations?.translate('profile_pic_updated') ??
                "Profile picture updated!"),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Changed to use localization
            content: Text(
                appLocalizations?.translate('upload_failed_connection') ??
                    "Upload failed. Please check your connection."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() => _isUploading = false);
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    var appLocalizations =
        AppLocalizations.of(context); // Added for localization

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        final isSmall =
            constraints.maxWidth < 400 || constraints.maxHeight < 700;

        return Column(
          children: [
            // Fixed Premium Rounded Header
            _buildAttractiveHeader(auth, isSmall),
            // Scrollable Options
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                child: Column(
                  children: [
                    _buildProfileCard([
                      _profileItem(
                          Icons.person_outline_rounded,
                          appLocalizations?.translate('account_info') ??
                              "Account Information", // Localized
                          appLocalizations?.translate('manage_details') ??
                              "Manage your details", // Localized
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AccountInfoScreen()));
                      }),
                      _profileItem(
                          Icons.history_rounded,
                          appLocalizations?.translate('booking_history') ??
                              "Booking History", // Localized
                          appLocalizations?.translate('blood_tests_checkups') ??
                              "Blood tests & Checkups", // Localized
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MyBookingsScreen()));
                      }),
                      _profileItem(
                          Icons.language_rounded,
                          appLocalizations?.translate('language_settings') ??
                              "Language Settings", // Localized
                          Provider.of<LanguageProvider>(context)
                              .appLocale
                              .languageCode
                              .toUpperCase(), () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ProfileLanguageScreen()));
                      }),
                    ]),
                    const SizedBox(height: 24),
                    _buildProfileCard([
                      _profileItem(
                          Icons.help_outline_rounded,
                          appLocalizations?.translate('help_support') ??
                              "Help & Support", // Localized
                          appLocalizations?.translate('get_assistance') ??
                              "Get assistance", // Localized
                          () {}),
                      _profileItem(
                          Icons.privacy_tip_outlined,
                          appLocalizations?.translate('privacy_policy') ??
                              "Privacy Policy", // Localized
                          appLocalizations?.translate('data_security') ??
                              "Data security", // Localized
                          () {}),
                      _profileItem(
                          Icons.logout_rounded,
                          appLocalizations?.translate('logout') ??
                              "Logout", // Localized
                          appLocalizations?.translate('exit_app') ??
                              "Exit app", // Localized
                          () => _logout(context), // Changed to _logout
                          isDestructive: true),
                    ]),
                    const SizedBox(height: 40),
                    Text("Version 1.0.2",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAttractiveHeader(AuthProvider auth, bool isSmall) {
    var appLocalizations =
        AppLocalizations.of(context); // Added for localization

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
          top: isSmall ? 40 : 60,
          bottom: isSmall ? 24 : 40,
          left: 24,
          right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkBlue, Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: isSmall ? 40 : 55,
                  backgroundColor: Colors.white10,
                  backgroundImage: (auth.profilePic != null &&
                          auth.profilePic!.isNotEmpty &&
                          auth.profilePic!.startsWith('http'))
                      ? NetworkImage(auth.profilePic!)
                      : null,
                  child: (auth.profilePic == null ||
                          auth.profilePic!.isEmpty ||
                          !auth.profilePic!.startsWith('http'))
                      ? Icon(Icons.person_rounded,
                          size: isSmall ? 40 : 55, color: Colors.white24)
                      : null,
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.darkBlue, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.edit_rounded,
                            color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 12 : 20),
          Text(
            auth.userName ??
                (appLocalizations?.translate('guest_user') ??
                    "Guest User"), // Localized
            style: GoogleFonts.outfit(
              fontSize: isSmall ? 20 : 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.email ??
                (appLocalizations?.translate('set_up_profile') ??
                    "Set up your profile"), // Localized
            style: GoogleFonts.plusJakartaSans(
              fontSize: isSmall ? 12 : 14,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _profileItem(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool isDestructive = false, bool isSmall = false}) {
    // Added isSmall default
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
          horizontal: isSmall ? 16 : 20, vertical: isSmall ? 4 : 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon,
            color: isDestructive ? Colors.red : AppTheme.primaryGreen,
            size: isSmall ? 18 : 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: isSmall ? 14 : 16,
          color: isDestructive ? Colors.red : AppTheme.darkBlue,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: isSmall ? 11 : 12,
          color: Colors.grey,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: Colors.grey, size: isSmall ? 20 : 24),
    );
  }
}
