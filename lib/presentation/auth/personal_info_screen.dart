import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/presentation/home/home_screen.dart';
import 'package:medinest/data/services/auth_service.dart';
import 'package:medinest/state/auth_provider.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.premiumBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Almost There!",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.075,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Help us personalize your healthcare experience",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.038,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel("How should we address you?"),
            Row(
              children: [
                _buildTitleChip("Mr."),
                const SizedBox(width: 12),
                _buildTitleChip("Ms."),
                const SizedBox(width: 12),
                _buildTitleChip("Dr."),
              ],
            ),
            const SizedBox(height: 32),
            _buildInputField(
              label: "Full Name",
              controller: _nameController,
              hint: "Enter your full name",
              icon: Icons.person_outline_rounded,
              focusNode: _focusNodes['name']!,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: "Date of Birth",
              controller: _dobController,
              hint: "Select your DOB",
              icon: Icons.calendar_today_outlined,
              focusNode: _focusNodes['dob']!,
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.now().subtract(const Duration(days: 6570)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
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
              label: "E-mail ID",
              controller: _emailController,
              hint: "For medical reports",
              icon: Icons.email_outlined,
              focusNode: _focusNodes['email']!,
            ),
            const SizedBox(height: 24),
            _buildInputField(
              label: "City",
              controller: _cityController,
              hint: "Detecting city...",
              icon: Icons.location_on_outlined,
              focusNode: _focusNodes['city']!,
              suffixIcon: _isLocationLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
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
                backgroundColor: AppTheme.darkBlue,
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 8,
              ),
              child: const Text(
                "Complete Profile",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.darkBlue,
        ),
      ),
    );
  }

  Widget _buildTitleChip(String label) {
    bool isSelected = _title == label;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (!mounted) return;
        setState(() => _title = label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade600,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: focusNode.hasFocus
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onTap: onTap,
            readOnly: onTap != null,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon,
                  color:
                      focusNode.hasFocus ? AppTheme.primaryGreen : Colors.grey),
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

    final result = await authService.updateProfile(
      phoneNumber: authProvider.phoneNumber ?? "",
      name: _nameController.text,
      dob: _dobController.text,
      email: _emailController.text,
      city: _cityController.text,
    );

    if (result != null) {
      if (!mounted) return;
      authProvider.updateUserInfo(_nameController.text);
      authProvider.completeProfile();
      _showWelcomeAnimation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save profile")),
      );
    }
  }

  void _showWelcomeAnimation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie/welcome.json',
                  repeat: false,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration * 0.8, () {
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "Welcome to MediNest!",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your profile is ready",
                  style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkBlue.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
