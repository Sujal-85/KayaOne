import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/presentation/booking/my_appointments_screen.dart';

class LabBookingDetailScreen extends StatelessWidget {
  final AppointmentItem appointment;

  const LabBookingDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final data = appointment.rawData;
    final tests = List<Map<String, dynamic>>.from(data['tests'] ?? []);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.5),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.darkBlue),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc?.translate('booking_details') ?? "Booking Details",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              appointment.status == 'upcoming'
                                  ? Icons.schedule_rounded
                                  : Icons.check_circle_rounded,
                              size: 48,
                              color: appointment.status == 'upcoming'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              appointment.status == 'upcoming'
                                  ? (loc?.translate('upcoming') ?? "Upcoming")
                                  : (loc?.translate('completed') ??
                                      "Completed"),
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${loc?.translate('booking_id') ?? 'Booking ID'}: #${appointment.id}",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Patient Details
                      Text(
                        loc?.translate('patient_details') ?? "Patient Details",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              Icons.person_outline_rounded,
                              loc?.translate('patient_name') ?? "Name",
                              data['patientName'] ?? 'N/A',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              Icons.phone_outlined,
                              loc?.translate('phone_number') ?? "Phone",
                              data['patientPhone'] ?? 'N/A',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Appointment Info
                      Text(
                        loc?.translate('appointment_info') ??
                            "Appointment Info",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              Icons.calendar_today_rounded,
                              loc?.translate('date') ?? "Date",
                              data['date'] ?? 'N/A',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              Icons.access_time_rounded,
                              loc?.translate('time_slot') ?? "Time Slot",
                              data['slot'] ?? 'N/A',
                            ),
                            const Divider(height: 24),
                            _buildDetailRow(
                              Icons.location_on_outlined,
                              loc?.translate('address') ?? "Address",
                              _formatAddress(data['address']),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tests Selected
                      if (tests.isNotEmpty) ...[
                        Text(
                          loc?.translate('tests_selected') ?? "Tests Selected",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...tests.map((test) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.teal.shade50),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          test['name'] ?? 'Test',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkBlue,
                                          ),
                                        ),
                                        if (test['desc'] != null)
                                          Text(
                                            test['desc'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${test['price']}",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      const SizedBox(height: 24),

                      // Payment Summary
                      Text(
                        loc?.translate('payment_summary') ?? "Payment Summary",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              loc?.translate('total_amount') ?? "Total Amount",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                            Text(
                              "₹${appointment.fee}",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkBlue,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'N/A';
    if (address is Map) {
      // Assuming typical address fields, adjust based on actual data
      final parts = [
        address['street'],
        address['city'],
        address['state'],
        address['zip']
      ].where((e) => e != null && e.toString().isNotEmpty).join(', ');
      return parts.isEmpty ? 'Address available' : parts;
    }
    return address.toString();
  }
}
