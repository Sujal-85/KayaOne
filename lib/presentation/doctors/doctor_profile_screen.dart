import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/doctor_provider.dart';
import 'package:medinest/state/auth_provider.dart';
import 'package:medinest/data/services/doctor_service.dart';
import 'package:medinest/presentation/booking/booking_success_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  int _selectedDateIndex = 0;
  String _selectedSlot = "";
  bool _isBooking = false;
  late List<DateTime> _projectedDates;
  final DoctorService _doctorService = DoctorService();

  final List<String> _slots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "01:00 PM",
    "02:00 PM",
    "05:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    _projectedDates =
        List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  }

  Future<void> _handleBooking(BuildContext context, AuthProvider auth,
      Map<String, dynamic> doctor) async {
    setState(() => _isBooking = true);

    final success = await _doctorService.bookAppointment(
      userId: auth.userId ?? "guest_id",
      doctorId: doctor['id'],
      doctorName: doctor['name'],
      date: _projectedDates[_selectedDateIndex],
      slot: _selectedSlot,
      fee: doctor['fee'],
    );

    setState(() => _isBooking = false);

    if (success) {
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        (route) => route.isFirst,
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to book appointment. Please try again."),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final doctor = doctorProvider.selectedDoctor;

    if (doctor == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'doctor_${doctor['id']}',
                child: Image.network(doctor['image'], fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor['name'],
                              style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkBlue)),
                          Text(doctor['specialty'],
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10)
                            ]),
                        child: const Icon(Icons.favorite_border_rounded,
                            color: Colors.pinkAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoStat("Exp", doctor['experience']),
                      _buildInfoStat("Rating", doctor['rating'].toString()),
                      _buildInfoStat("Reviews", doctor['reviews'].toString()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text("About Doctor",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkBlue)),
                  const SizedBox(height: 8),
                  Text(
                    "Top-rated ${doctor['specialty']} with extensive experience in treating complex cases. Known for patient-centric care and advanced medical techniques.",
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Text("Select Schedule",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkBlue)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _projectedDates.length,
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedDateIndex == index;
                        DateTime date = _projectedDates[index];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDateIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 70,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? AppTheme.darkBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade200),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(DateFormat('EEE').format(date),
                                    style: GoogleFonts.plusJakartaSans(
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey,
                                        fontSize: 11)),
                                Text(DateFormat('dd').format(date),
                                    style: GoogleFonts.outfit(
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.darkBlue,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _slots.map((slot) {
                      bool isSelected = _selectedSlot == slot;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlot = slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade200),
                          ),
                          child: Text(slot,
                              style: GoogleFonts.plusJakartaSans(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.darkBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: (_selectedSlot.isEmpty || _isBooking)
                        ? null
                        : () => _handleBooking(context, authProvider, doctor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isBooking
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text("Book Appointment • ₹${doctor['fee']}",
                            style: GoogleFonts.outfit(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkBlue)),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
