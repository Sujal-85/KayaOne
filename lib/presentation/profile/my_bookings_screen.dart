import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/data/services/booking_service.dart';
import 'package:kayaone/core/localization/app_localizations.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = true;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userId != null) {
      final results = await _bookingService.getUserBookings(auth.userId!);
      if (results != null) {
        setState(() {
          _bookings = results;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations?.translate('my_bookings') ?? "My Bookings",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _bookings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    var appLocalizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
              appLocalizations?.translate('no_bookings_yet') ??
                  "No Bookings Yet",
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue)),
          const SizedBox(height: 8),
          Text(
              appLocalizations?.translate('medical_history_placeholder') ??
                  "Your medical test history will appear here",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    var appLocalizations = AppLocalizations.of(context);
    final String status = booking['status'] ?? "Confirmed";
    final bool isCompleted = status == "Completed";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.green : Colors.blue)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              Text(
                booking['date'] ?? "",
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations?.translate('blood_collection_labs') ??
                "Blood Collection & Labs",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppTheme.darkBlue),
          ),
          const SizedBox(height: 4),
          Text(
            "${booking['tests']?.length ?? 0} ${appLocalizations?.translate('tests_selected') ?? 'Tests Selected'}",
            style:
                GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking['address'] ??
                      (appLocalizations?.translate('collection_address') ??
                          "Collection Address"),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: AppTheme.darkBlue.withOpacity(0.7)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "₹${booking['totalAmount']}",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
