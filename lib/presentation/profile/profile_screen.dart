import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/state/language_provider.dart';
import 'package:medinest/data/services/storage_service.dart';
import 'package:medinest/data/services/auth_service.dart';
import 'package:medinest/presentation/profile/account_info_screen.dart';
import 'package:medinest/presentation/profile/my_bookings_screen.dart';
import 'package:medinest/presentation/profile/profile_language_screen.dart';

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

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isUploading = true);
      final url = await _storageService.uploadProfilePic(
          auth.userId ?? 'guest', File(image.path));

      if (url != null) {
        // Update in MongoDB via backend
        await _authService.updateProfile(
          phoneNumber: auth.phoneNumber!,
          name: auth.userName ?? "",
          dob: auth.dob ?? "",
          email: auth.email ?? "",
          city: auth.city ?? "",
          // Note: Backend updateProfile might need to be extended to support profilePic
          // For now we assume updateProfile handles it or we add a new endpoint
        );
        // Refresh local state
        _refreshProfile();
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Fixed Premium Rounded Header
          _buildAttractiveHeader(auth),
          // Scrollable Options
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                children: [
                  _buildProfileCard([
                    _profileItem(Icons.person_outline_rounded,
                        "Account Information", "Manage your details", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AccountInfoScreen()));
                    }),
                    _profileItem(Icons.history_rounded, "Booking History",
                        "Blood tests & Checkups", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MyBookingsScreen()));
                    }),
                    _profileItem(
                        Icons.language_rounded,
                        "Language Settings",
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
                    _profileItem(Icons.help_outline_rounded, "Help & Support",
                        "Get assistance", () {}),
                    _profileItem(Icons.privacy_tip_outlined, "Privacy Policy",
                        "Data security", () {}),
                    _profileItem(Icons.logout_rounded, "Logout", "Exit app",
                        () => _showLogoutDialog(context, auth),
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
      ),
    );
  }

  Widget _buildAttractiveHeader(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
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
                  radius: 55,
                  backgroundColor: Colors.white10,
                  backgroundImage: auth.profilePic != null
                      ? NetworkImage(auth.profilePic!)
                      : null,
                  child: auth.profilePic == null
                      ? const Icon(Icons.person_rounded,
                          size: 55, color: Colors.white24)
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
          const SizedBox(height: 20),
          Text(
            auth.userName ?? "Guest User",
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.email ?? "Set up your profile",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
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
      {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: isDestructive ? Colors.red : AppTheme.darkBlue,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Text("Are you sure you want to logout?",
            style: GoogleFonts.plusJakartaSans()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              auth.logout();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
