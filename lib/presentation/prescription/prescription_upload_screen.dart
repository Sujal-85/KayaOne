import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:kayaone/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/state/booking_provider.dart';
import 'package:kayaone/presentation/booking/address_selection_screen.dart';
import 'package:kayaone/presentation/booking/widgets/booking_step_indicator.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() =>
      _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  int _currentStep = 0;
  bool _isPicking = false;
  bool _isUpdatingProfile = false;
  final StorageService _storageService = StorageService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedBloodGroup;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = auth.userName ?? '';
    _emailController.text = auth.email ?? '';
    _cityController.text = auth.city ?? '';
    _selectedBloodGroup = auth.bloodGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileAndContinue() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final booking = Provider.of<BookingProvider>(context, listen: false);
    final authService = AuthService();

    setState(() => _isUpdatingProfile = true);

    try {
      final success = await authService.updateProfile(
        phoneNumber: auth.phoneNumber ?? '',
        name: _nameController.text,
        dob: auth.dob ?? '01-01-2000',
        email: _emailController.text,
        city: _cityController.text,
        bloodGroup: _selectedBloodGroup,
      );

      if (success != null) {
        auth.updateUserInfo(
          name: _nameController.text,
          email: _emailController.text,
          city: _cityController.text,
          bloodGroup: _selectedBloodGroup,
        );
        booking.setPatientDetails(_nameController.text, auth.phoneNumber ?? "");
        setState(() => _currentStep = 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    } catch (e) {
      debugPrint("Update error: $e");
    } finally {
      setState(() => _isUpdatingProfile = false);
    }
  }

  Future<void> _pickFile(BookingProvider provider) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isPicking = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        final publicUrl = await _storageService.uploadPrescription(
          auth.userId ?? 'guest',
          File(result.files.single.path!),
        );
        if (publicUrl != null) {
          provider.setPrescription(publicUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Upload failed. Please check Storage policies."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    var appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          _currentStep == 0
              ? (appLocalizations?.translate('patient_details_title') ??
                  "Patient Details")
              : (appLocalizations?.translate('upload_prescription_title') ??
                  "Upload Prescription"),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: (_currentStep == 0 && !Navigator.of(context).canPop())
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.darkBlue),
                onPressed: () {
                  if (_currentStep == 1) {
                    setState(() => _currentStep = 0);
                  } else {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingStepIndicator(currentStep: _currentStep),
              const SizedBox(height: 24),
              if (_currentStep == 0)
                _buildUserInfoStep(appLocalizations)
              else
                _buildUploadStep(bookingProvider, appLocalizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoStep(AppLocalizations? loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc?.translate('review_info') ?? "Review Information",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc?.translate('review_info_desc') ??
              "Ensure your medical details are up to date for better diagnostic accuracy.",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        _buildTextField(loc?.translate('full_name') ?? "Full Name",
            _nameController, Icons.person_outline_rounded),
        const SizedBox(height: 20),
        _buildTextField(
            loc?.translate('email_id') ??
                "E-mail ID", // Using existing key for email
            _emailController,
            Icons.email_outlined),
        const SizedBox(height: 20),
        _buildTextField(loc?.translate('city') ?? "City", _cityController,
            Icons.location_on_outlined),
        const SizedBox(height: 20),
        _buildBloodGroupPicker(loc),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: _isUpdatingProfile ? null : _updateProfileAndContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.darkBlue,
            minimumSize: const Size(double.infinity, 64),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
          ),
          child: _isUpdatingProfile
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  loc?.translate('next_step') ?? "Next Step",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primaryGreen),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodGroupPicker(AppLocalizations? loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc?.translate('blood_group') ?? "Blood Group",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkBlue.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _bloodGroups.map((group) {
            final isSelected = _selectedBloodGroup == group;
            return GestureDetector(
              onTap: () => setState(() => _selectedBloodGroup = group),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.grey.shade200,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              blurRadius: 10)
                        ]
                      : [],
                ),
                child: Text(
                  group,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUploadStep(
      BookingProvider bookingProvider, AppLocalizations? loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc?.translate('upload_prescription_hero') ?? "Upload Prescription",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          loc?.translate('upload_prescription_desc') ??
              "Uploading a doctor's prescription ensures accurate verification of your tests.",
          style: GoogleFonts.plusJakartaSans(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _isPicking ? null : () => _pickFile(bookingProvider),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 50),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                if (_isPicking)
                  const CircularProgressIndicator(color: AppTheme.primaryGreen)
                else ...[
                  SizedBox(
                    height: 120,
                    child: Lottie.asset(
                      'assets/lottie/upload.json',
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud_upload_outlined,
                          size: 72,
                          color: AppTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(loc?.translate('tap_to_select') ?? "Tap to Select File",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppTheme.darkBlue)),
                  const SizedBox(height: 6),
                  Text(
                      loc?.translate('upload_supports') ??
                          "Supports PDF, JPG, PNG",
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
        if (bookingProvider.prescriptionPath != null &&
            bookingProvider.prescriptionPath!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.primaryGreen.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primaryGreen, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    bookingProvider.prescriptionPath!.split('/').last,
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                  onPressed: () => bookingProvider.setPrescription(null),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 60),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddressSelectionScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Text(loc?.translate('skip') ?? "Skip",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: (bookingProvider.prescriptionPath == null ||
                        bookingProvider.prescriptionPath == "")
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddressSelectionScreen()),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(loc?.translate('continue') ?? "Continue",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
