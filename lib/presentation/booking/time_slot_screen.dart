import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/booking_provider.dart';
import 'package:kayaone/presentation/booking/checkout_screen.dart';
import 'package:kayaone/presentation/booking/widgets/booking_step_indicator.dart';

class TimeSlotScreen extends StatefulWidget {
  const TimeSlotScreen({super.key});

  @override
  State<TimeSlotScreen> createState() => _TimeSlotScreenState();
}

class _TimeSlotScreenState extends State<TimeSlotScreen> {
  int _selectedDateIndex = 0;
  String _selectedSlot = "";

  late List<DateTime> _projectedDates;

  final List<String> _slots = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "05:00 PM - 06:00 PM"
  ];

  @override
  void initState() {
    super.initState();
    // Generate next 7 days
    _projectedDates =
        List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Schedule Pickup",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookingStepIndicator(currentStep: 2),
              const SizedBox(height: 16),
              Text(
                "When should we visit?",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _projectedDates.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedDateIndex == index;
                    DateTime date = _projectedDates[index];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.darkBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color: AppTheme.darkBlue.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4))
                                ]
                              : [],
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(DateFormat('dd MMM').format(date),
                                style: GoogleFonts.outfit(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.darkBlue,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Available Time Slots",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _slots.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedSlot == _slots[index];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = _slots[index]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryGreen.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.grey.shade200,
                            width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _slots[index],
                        style: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? AppTheme.primaryGreen
                              : AppTheme.darkBlue.withOpacity(0.7),
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _selectedSlot.isEmpty
                    ? null
                    : () {
                        String formattedDate = DateFormat('yyyy-MM-dd')
                            .format(_projectedDates[_selectedDateIndex]);
                        bookingProvider.setDateTime(
                            formattedDate, _selectedSlot);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const CheckoutScreen()),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Review Booking",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
