import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:medinest/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:medinest/core/localization/app_localizations.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/state/booking_provider.dart';
import 'package:medinest/presentation/booking/address_selection_screen.dart';
import 'package:medinest/presentation/booking/widgets/booking_step_indicator.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() =>
      _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  bool _isPicking = false;
  final StorageService _storageService = StorageService();

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
        }
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    } finally {
      setState(() => _isPicking = false);
    }
  }

  Future<void> _showEditPatientDetailsDialog(BookingProvider provider) async {
    final nameController = TextEditingController(text: provider.patientName);
    final phoneController = TextEditingController(text: provider.patientPhone);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Edit Patient Details",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Patient Name",
                labelStyle: GoogleFonts.plusJakartaSans(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: GoogleFonts.plusJakartaSans(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.setPatientDetails(
                  nameController.text, phoneController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darkBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Save", style: GoogleFonts.plusJakartaSans()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final loc = AppLocalizations.of(context);

    // Auto-fill patient details if not already set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bookingProvider.patientName == null) {
        bookingProvider.setPatientDetails(
            authProvider.userName ?? "User", authProvider.phoneNumber ?? "");
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          loc?.translate('onboarding_2_title') ?? 'Upload Prescription',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookingStepIndicator(currentStep: 0),
              const SizedBox(height: 16),
              Text(
                "Required for your tests",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Uploading a doctor's prescription helps us verify your tests and ensures accuracy.",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Patient Info Card (Auto-filled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: AppTheme.primaryGreen.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02), blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: AppTheme.primaryGreen),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingProvider.patientName ?? "Loading...",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        Text(
                          bookingProvider.patientPhone ?? "",
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          _showEditPatientDetailsDialog(bookingProvider),
                      child: Text("Change",
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreen)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Upload Container
              GestureDetector(
                onTap: _isPicking ? null : () => _pickFile(bookingProvider),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        style: BorderStyle.solid,
                        width: 2),
                  ),
                  child: Column(
                    children: [
                      if (_isPicking)
                        const CircularProgressIndicator(
                            color: AppTheme.primaryGreen)
                      else ...[
                        SizedBox(
                          height: 100,
                          child: Lottie.asset(
                            'assets/lottie/upload.json',
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.cloud_upload_outlined,
                                    size: 64, color: AppTheme.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text("Tap to Upload Prescription",
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppTheme.darkBlue)),
                        const SizedBox(height: 4),
                        Text("PDF, JPG, PNG (Max 5MB)",
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
              ),

              if (bookingProvider.prescriptionPath != null &&
                  bookingProvider.prescriptionPath!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.primaryGreen.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bookingProvider.prescriptionPath!.split('/').last,
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep_rounded,
                            color: Colors.redAccent),
                        onPressed: () => bookingProvider.setPrescription(null),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddressSelectionScreen()),
                        );
                      },
                      child: Text("Skip for now",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w700)),
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
                                    builder: (_) =>
                                        const AddressSelectionScreen()),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Text("Continue",
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
