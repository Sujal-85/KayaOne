import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/booking_provider.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/data/services/booking_service.dart';
import 'package:kayaone/presentation/booking/booking_success_screen.dart';
import 'package:kayaone/presentation/booking/widgets/booking_step_indicator.dart';
import 'package:kayaone/data/services/notification_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isBooking = false;
  final BookingService _bookingService = BookingService();

  Future<void> _handleBooking(
      BuildContext context, AuthProvider auth, BookingProvider booking) async {
    setState(() => _isBooking = true);

    final success =
        await _bookingService.createBooking(auth.userId ?? "guest_id", booking);

    setState(() => _isBooking = false);

    if (success) {
      // Notification
      NotificationService().showNotification(
        title: "Booking Confirmed! ✅",
        body:
            "Your booking for ${booking.selectedDate} at ${booking.selectedSlot} has been confirmed.",
      );

      booking.clear();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        (route) => route.isFirst,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to place booking. Please try again."),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final total = bookingProvider.selectedTests
        .fold<int>(0, (sum, item) => sum + (item['price'] as int));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Review & Pay",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const BookingStepIndicator(currentStep: 3),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Patient & Collection Info
                              _buildSectionHeader("Service Details"),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10)
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildDetailRow(
                                        Icons.person_rounded,
                                        "Patient",
                                        bookingProvider.patientName ?? "User"),
                                    const Divider(height: 32),
                                    _buildDetailRow(
                                        Icons.location_on_rounded,
                                        "Address",
                                        bookingProvider.selectedAddress ??
                                            "Not set"),
                                    const Divider(height: 32),
                                    _buildDetailRow(
                                        Icons.calendar_month_rounded,
                                        "Schedule",
                                        "${bookingProvider.selectedDate}, ${bookingProvider.selectedSlot}"),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),
                              _buildSectionHeader("Selected Tests"),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10)
                                  ],
                                ),
                                child: bookingProvider.selectedTests.isEmpty
                                    ? ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryGreen
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.description_rounded,
                                              color: AppTheme.primaryGreen),
                                        ),
                                        title: Text(
                                            "Prescription-Based Service",
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.darkBlue)),
                                        subtitle: Text(
                                            "Diagnostics will be confirmed after review",
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        trailing: Text("₹0",
                                            style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.primaryGreen,
                                                fontSize: 16)),
                                      )
                                    : Column(
                                        children: bookingProvider.selectedTests
                                            .map((test) {
                                        return ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 8),
                                          title: Text(test['name']!,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppTheme.darkBlue)),
                                          subtitle: Text(
                                              test['category'] ?? "General",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                          trailing: Text("₹${test['price']}",
                                              style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w800,
                                                  color: AppTheme.primaryGreen,
                                                  fontSize: 16)),
                                        );
                                      }).toList()),
                              ),

                              const SizedBox(height: 32),
                              _buildSectionHeader("Payment Summary"),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBlue,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                        color:
                                            AppTheme.darkBlue.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10))
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _priceRow(
                                        "Subtotal", "₹$total", Colors.white70),
                                    _priceRow("Collection Fee", "₹99",
                                        Colors.white70),
                                    _priceRow("Platform Discount", "-₹50",
                                        AppTheme.primaryGreen,
                                        isDiscount: true),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Divider(color: Colors.white12),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Total Amount",
                                            style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600)),
                                        Text("₹${total + 99 - 50}",
                                            style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _isBooking
                                    ? null
                                    : () => _handleBooking(
                                        context, authProvider, bookingProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 64),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  elevation: 0,
                                ),
                                child: _isBooking
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2))
                                    : Text("Confirm & Book Now",
                                        style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppTheme.darkBlue,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value, Color color,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          Text(value,
              style: GoogleFonts.outfit(
                  color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}
