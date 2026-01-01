import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/presentation/home/home_screen.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:kayaone/presentation/auth/login_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String _title = "Mr.";
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _referralController = TextEditingController();
  bool _isLocationLoading = false;

  final Map<String, FocusNode> _focusNodes = {
    'name': FocusNode(),
    'dob': FocusNode(),
    'email': FocusNode(),
    'city': FocusNode(),
    'referral': FocusNode(),
  };

  @override
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permissions are denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Location permissions are permanently denied")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (!mounted) return;
        setState(() {
          _cityController.text =
              "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location: $e")),
      );
    } finally {
      setState(() => _isLocationLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.premiumBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_images/image3.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ),
          LayoutBuilder(builder: (context, constraints) {
            final isSmall =
                constraints.maxWidth < 400 || constraints.maxHeight < 700;
            final buttonHeight = isSmall ? 56.0 : 64.0;
            final buttonFontSize = isSmall ? 18.0 : 20.0;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      appLocalizations?.translate('almost_there') ??
                          "Almost There!",
                      style: GoogleFonts.outfit(
                        fontSize: isSmall ? 32 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appLocalizations?.translate('personalize_experience') ??
                          "Help us personalize your healthcare experience",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmall ? 14 : 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel(appLocalizations?.translate('address_you') ??
                        "How should we address you?"),
                    Row(
                      children: [
                        _buildTitleChip("Mr.", isSmall),
                        const SizedBox(width: 12),
                        _buildTitleChip("Ms.", isSmall),
                        const SizedBox(width: 12),
                        _buildTitleChip("Dr.", isSmall),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildInputField(
                      label: appLocalizations?.translate('full_name') ??
                          "Full Name",
                      controller: _nameController,
                      hint: appLocalizations?.translate('enter_full_name') ??
                          "Enter your full name",
                      icon: Icons.person_outline_rounded,
                      focusNode: _focusNodes['name']!,
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label:
                          appLocalizations?.translate('dob') ?? "Date of Birth",
                      controller: _dobController,
                      hint: appLocalizations?.translate('select_dob') ??
                          "Select your DOB",
                      icon: Icons.calendar_today_outlined,
                      focusNode: _focusNodes['dob']!,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now()
                              .subtract(const Duration(days: 6570)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppTheme.primaryGreen,
                                  onPrimary: Colors.white,
                                  onSurface: AppTheme.darkBlue,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _dobController.text =
                                "${picked.day}-${picked.month}-${picked.year}";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: appLocalizations?.translate('email_id') ??
                          "E-mail ID",
                      controller: _emailController,
                      hint:
                          appLocalizations?.translate('medical_reports_hint') ??
                              "For medical reports",
                      icon: Icons.email_outlined,
                      focusNode: _focusNodes['email']!,
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: appLocalizations?.translate('city') ?? "City",
                      controller: _cityController,
                      hint: appLocalizations?.translate('detecting_city') ??
                          "Detecting city...",
                      icon: Icons.location_on_outlined,
                      focusNode: _focusNodes['city']!,
                      suffixIcon: _isLocationLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.primaryGreen))
                          : IconButton(
                              icon: const Icon(Icons.my_location_rounded,
                                  color: AppTheme.primaryGreen),
                              onPressed: _getCurrentLocation,
                            ),
                    ),
                    const SizedBox(height: 60),
                    ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, buttonHeight),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Text(
                        appLocalizations?.translate('complete_profile') ??
                            "Complete Profile",
                        style: GoogleFonts.outfit(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitleChip(String label, [bool isSmall = false]) {
    bool isSelected = _title == label;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (!mounted) return;
        setState(() => _title = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 20 : 28, vertical: isSmall ? 10 : 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white24,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: isSmall ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9), // Increased opacity
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focusNode.hasFocus
                  ? AppTheme.primaryGreen
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onTap: onTap,
            readOnly: onTap != null,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black, // Changed to black
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Colors.black54), // Dark hint for contrast
              prefixIcon: Icon(icon,
                  color: focusNode.hasFocus
                      ? AppTheme.primaryGreen
                      : Colors.black54), // Dark icons
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveAndContinue() async {
    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final authService = AuthService();

    debugPrint(
        "Attempting to update profile for Phone: ${authProvider.phoneNumber}");

    if (authProvider.phoneNumber == null || authProvider.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Error: Phone number is missing. Please login again.")),
      );
      return;
    }

    final result = await authService.updateProfile(
      phoneNumber: authProvider.phoneNumber ?? "",
      name: _nameController.text,
      dob: _dobController.text,
      email: _emailController.text,
      city: _cityController.text,
    );

    if (result != null) {
      if (!mounted) return;
      authProvider.updateUserInfo(name: _nameController.text);
      authProvider.completeProfile();
      _showWelcomeAnimation();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to save profile. Check logs for details.")),
      );
    }
  }

  void _showWelcomeAnimation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          // Auto-navigate to Home
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            }
          });

          return Scaffold(
            backgroundColor: AppTheme.darkBlue,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryGreen,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Welcome to KayaOne!",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your profile is ready",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white70,
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
}
