import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/data/services/auth_service.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _dobController;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.userName);
    _emailController = TextEditingController(text: auth.email);
    _cityController = TextEditingController(text: auth.city);
    _dobController = TextEditingController(text: auth.dob);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final result = await _authService.updateProfile(
      phoneNumber: auth.phoneNumber!,
      name: _nameController.text,
      dob: _dobController.text,
      email: _emailController.text,
      city: _cityController.text,
      profilePic: auth.profilePic,
    );

    setState(() => _isLoading = false);

    if (result != null) {
      auth.login(
        auth.phoneNumber!,
        userId: result['_id'],
        name: result['name'],
        email: result['email'],
        city: result['city'],
        dob: result['dob'],
        profilePic: result['profilePic'],
        isProfileComplete: true,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profile updated successfully"),
              backgroundColor: AppTheme.primaryGreen),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to update profile"),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Account Info",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, color: AppTheme.darkBlue)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  "Full Name", _nameController, Icons.person_outline_rounded),
              _buildTextField(
                  "Email Address", _emailController, Icons.email_outlined),
              _buildTextField("Date of Birth", _dobController,
                  Icons.calendar_today_outlined,
                  hint: "DD/MM/YYYY"),
              _buildTextField(
                  "City", _cityController, Icons.location_city_outlined),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Save Changes",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.darkBlue)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) => value!.isEmpty ? "Required field" : null,
          ),
        ],
      ),
    );
  }
}
