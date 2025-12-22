import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/data/services/doctor_service.dart';
import 'package:medinest/presentation/doctors/doctor_listing_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  List<dynamic> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.userId != null) {
      final results = await _doctorService.getUserAppointments(auth.userId!);
      if (results != null) {
        setState(() {
          _appointments = results;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("My Appointments",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorListingScreen()));
            },
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : _appointments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _appointments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _appointments.length) {
                      return const SizedBox(height: 120);
                    }
                    final appointment = _appointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text("No Appointments Found",
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue)),
          const SizedBox(height: 8),
          Text("Book your first doctor consultation today!",
              style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
          const SizedBox(height: 32),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DoctorListingScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Find a Doctor",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_search_rounded,
                    color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'] ?? "Doctor",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.darkBlue),
                    ),
                    Text(
                      "Consultation",
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                "₹${appointment['fee']}",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppTheme.primaryGreen),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile(Icons.calendar_month_rounded,
                  appointment['appointmentDate'] ?? ""),
              _infoTile(Icons.access_time_rounded,
                  appointment['appointmentSlot'] ?? ""),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkBlue.withOpacity(0.8))),
      ],
    );
  }
}
