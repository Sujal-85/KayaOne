import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:kayaone/presentation/home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/auth_provider.dart';
import 'package:kayaone/data/services/doctor_service.dart';
import 'package:kayaone/data/services/booking_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kayaone/presentation/booking/lab_booking_detail_screen.dart';
import 'package:kayaone/presentation/booking/doctor_booking_detail_screen.dart';
import 'package:kayaone/presentation/booking/booking_guide_screen.dart';
import 'package:kayaone/presentation/doctors/doctor_listing_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
// Add this import

enum AppointmentType { doctor, lab }

class AppointmentItem {
  final AppointmentType type;
  final String id;
  final String title;
  final String subtitle;
  final String fee;
  final DateTime dateTime;
  final String status; // "upcoming", "completed", "cancelled"
  final Map<String, dynamic> rawData;

  AppointmentItem({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.fee,
    required this.dateTime,
    required this.status,
    required this.rawData,
  });
}

class MyAppointmentsScreen extends StatefulWidget {
  final AppointmentType? filterType;
  final bool isEmbedded;
  const MyAppointmentsScreen(
      {super.key, this.filterType, this.isEmbedded = false});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final DoctorService _doctorService = DoctorService();
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  List<AppointmentItem> _appointments = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments({bool isRefresh = false}) async {
    final loc = AppLocalizations.of(context);
    if (!isRefresh) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    } else {
      if (mounted) setState(() => _isRefreshing = true);
    }

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.userId == null) {
        // User not logged in, show empty state instead of error
        if (mounted) {
          setState(() {
            _appointments = [];
            _isLoading = false;
            _isRefreshing = false;
          });
        }
        return;
      }

      final doctorAppointments =
          await _doctorService.getUserAppointments(auth.userId!);
      final labBookings = await _bookingService.getUserBookings(auth.userId!);

      final List<AppointmentItem> allAppointments = [];

      // Process doctor appointments
      if (doctorAppointments != null) {
        for (var apt in doctorAppointments) {
          try {
            final dateStr = apt['appointmentDate']?.toString();
            final slot = apt['appointmentSlot']?.toString();
            if (dateStr == null || slot == null) continue;

            final dateTime = _parseDateTime(dateStr, slot);

            allAppointments.add(AppointmentItem(
              type: AppointmentType.doctor,
              id: apt['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: apt['doctorName']?.toString() ??
                  loc?.translate('doctor_consultation') ??
                  'Doctor Consultation',
              subtitle: loc?.translate('in_person_video') ??
                  'In-Person/Video Consultation',
              fee: apt['fee']?.toString() ?? '0',
              dateTime: dateTime,
              status:
                  dateTime.isAfter(DateTime.now()) ? 'upcoming' : 'completed',
              rawData: apt,
            ));
          } catch (e) {
            debugPrint("Error parsing doctor appointment: $e");
          }
        }
      }

      // Process lab bookings
      if (labBookings != null) {
        for (var booking in labBookings) {
          try {
            final dateStr = booking['date']?.toString();
            final slot = booking['slot']?.toString();
            final dateTime = _parseDateTime(
                dateStr ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
                slot ?? '10:00 AM');

            allAppointments.add(AppointmentItem(
              type: AppointmentType.lab,
              id: booking['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: loc?.translate('sample_collection') ?? 'Sample Collection',
              subtitle: loc?.translate('home_sample_collection') ??
                  'Home Sample Collection',
              fee: booking['totalAmount']?.toString() ?? '0',
              dateTime: dateTime,
              status:
                  dateTime.isAfter(DateTime.now()) ? 'upcoming' : 'completed',
              rawData: booking,
            ));
          } catch (e) {
            debugPrint("Error parsing lab booking: $e");
          }
        }
      }

      // Filter based on widget.filterType
      if (widget.filterType != null) {
        allAppointments.retainWhere((item) => item.type == widget.filterType);
      }

      // Sort: Upcoming first, then by date descending
      allAppointments.sort((a, b) {
        if (a.status == 'upcoming' && b.status != 'upcoming') return -1;
        if (b.status == 'upcoming' && a.status != 'upcoming') return 1;
        return b.dateTime.compareTo(a.dateTime);
      });

      if (mounted) {
        setState(() {
          _appointments = allAppointments;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      if (mounted) {
        setState(() {
          _errorMessage = loc?.translate('failed_load_appointments') ??
              "Failed to load appointments. Tap to retry.";
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  DateTime _parseDateTime(String dateStr, String slot) {
    try {
      DateTime date;
      try {
        date = DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (_) {
        date = DateTime.now(); // Fallback
      }

      // Safe slot parsing
      int hour = 9;
      int minute = 0;

      if (slot.contains('-')) {
        // Handle range like "06:00 AM - 07:00 AM" -> take start time
        final startTime = slot.split('-')[0].trim();
        final isPM = startTime.toUpperCase().contains('PM');
        final timeClean = startTime.replaceAll(RegExp(r'[A-Za-z]'), '').trim();
        final parts = timeClean.split(':');
        if (parts.isNotEmpty) {
          hour = int.tryParse(parts[0]) ?? 9;
          if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
        }
      } else {
        // Fallback for simple formats
        final isPM = slot.toUpperCase().contains('PM');
        final parts =
            slot.replaceAll(RegExp(r'[A-Za-z]'), '').trim().split(':');
        if (parts.isNotEmpty) {
          hour = int.tryParse(parts[0]) ?? 9;
          if (parts.length > 1) minute = int.tryParse(parts[1]) ?? 0;
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
        }
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint("Date parsing error: $e for date: $dateStr slot: $slot");
      return DateTime.now();
    }
  }

  Future<void> _cancelAppointment(AppointmentItem appointment) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            loc?.translate('cancel_appointment_title') ?? "Cancel Appointment?",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(loc?.translate('cancel_appointment_desc') ??
            "This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(loc?.translate('no') ?? "No")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc?.translate('yes_cancel') ?? "Yes, Cancel",
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc?.translate('appointment_cancelled') ??
                  "Appointment cancelled successfully")),
        );
      }
      _fetchAppointments(isRefresh: true);
    }
  }

  String get _title {
    final loc = AppLocalizations.of(context);
    if (widget.filterType == AppointmentType.lab) {
      return loc?.translate('blood_collection_labs') ?? "Blood Collections";
    }
    if (widget.filterType == AppointmentType.doctor) {
      return loc?.translate('my_doctors') ?? "My Doctors";
    }
    return loc?.translate('my_bookings') ?? "All Bookings";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50), // Top spacing for background visibility
            Expanded(
              child: Container(
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
                child: Column(
                  children: [
                    _buildEmbeddedHeader(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppTheme.primaryGreen,
                        onRefresh: () => _fetchAppointments(isRefresh: true),
                        child: _buildContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return _buildScaffold();
  }

  Widget _buildEmbeddedHeader() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      // color: AppTheme.backgroundColor, // Removed to show background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.filterType == AppointmentType.lab
                ? (loc?.translate('my_bookings') ?? "My Bookings")
                : (loc?.translate('my_doctors') ?? "My Doctors"),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue, // Reverted to dark blue
            ),
          ),
          Row(
            children: [
              if (widget.filterType == AppointmentType.lab)
                _buildNewBookingButton(loc?.translate('Book') ?? "Book", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookingGuideScreen(
                              isDoctorBooking: false)));
                }),
              if (widget.filterType == AppointmentType.doctor)
                _buildNewBookingButton(loc?.translate('find_doctor') ?? "Find",
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DoctorListingScreen()));
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewBookingButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryGreen),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent for background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () async {
            final didPop = await Navigator.maybePop(context);
            if (!didPop) HomeScreenState.of(context)?.setIndex(0);
          },
        ),
        title: Text(_title,
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.filterType == AppointmentType.lab ||
              widget.filterType == null)
            IconButton(
              icon: const Icon(Icons.add_a_photo_outlined,
                  color: AppTheme.primaryGreen),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const BookingGuideScreen(isDoctorBooking: false))),
            ),
          if (widget.filterType == AppointmentType.doctor)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppTheme.primaryGreen),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DoctorListingScreen())),
            ),
          const SizedBox(width: 8),
        ],
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
            const SizedBox(height: 100), // More space for Scaffold app bar
            Expanded(
              child: Container(
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
                child: RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () => _fetchAppointments(isRefresh: true),
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.filterType == AppointmentType.doctor) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DoctorListingScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const BookingGuideScreen(isDoctorBooking: false),
              ),
            );
          }
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Book New",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage != null) {
      return Center(
        child: GestureDetector(
          onTap: () => _fetchAppointments(),
          child:
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_appointments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchAppointments(isRefresh: true),
      color: AppTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _appointments.length + 1,
        itemBuilder: (context, index) {
          if (index == _appointments.length) return const SizedBox(height: 120);
          return _buildAdvancedAppointmentCard(_appointments[index]);
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    String title = loc?.translate('no_active_bookings') ?? "No Active Bookings";
    String subtitle = loc?.translate('schedule_service_desc') ??
        "Schedule a service to manage your health";

    if (widget.filterType == AppointmentType.doctor) {
      title = loc?.translate('no_doctor_visits') ?? "No Doctor Visits";
      subtitle = loc?.translate('book_appt_desc') ??
          "Book an appointment with top specialists";
    } else if (widget.filterType == AppointmentType.lab) {
      title = loc?.translate('no_blood_collections') ?? "No Blood Collections";
      subtitle = loc?.translate('book_home_coll_desc') ??
          "Book home collection for blood tests";
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/No Data Animation.json',
                width: 250, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(title,
                style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)), // White title
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70)), // White subtitle
            const SizedBox(height: 12),
            if (widget.filterType == AppointmentType.doctor ||
                widget.filterType == null) ...[
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: _buildActionCard(
                    loc?.translate('find_doctor') ?? "Find a Doctor",
                    Icons.person_search_rounded,
                    AppTheme.primaryGreen,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DoctorListingScreen())),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.filterType == AppointmentType.lab ||
                widget.filterType == null) ...[
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: _buildActionCard(
                    loc?.translate('book_slot_now') ?? "Book Slot Now",
                    Icons.bloodtype_outlined,
                    Colors.redAccent,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BookingGuideScreen(
                                isDoctorBooking: false))),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            // Removed AI Assistant card from here
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkBlue),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedAppointmentCard(AppointmentItem appointment) {
    final loc = AppLocalizations.of(context);
    final isUpcoming = appointment.status == 'upcoming';

    // Gradients for types
    final gradientColors = appointment.type == AppointmentType.doctor
        ? [const Color(0xFF009245), const Color(0xFFFCEE21)] // Green/Yellow
        : [const Color(0xFF662D8C), const Color(0xFFED1E79)]; // Purple/Pink

    return GestureDetector(
      onTap: () {
        if (appointment.type == AppointmentType.doctor) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    DoctorBookingDetailScreen(appointment: appointment)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    LabBookingDetailScreen(appointment: appointment)),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // TOP SECTION: Icon + Title + Status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient Icon Box
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.first.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        appointment.type == AppointmentType.doctor
                            ? Icons.person_rounded
                            : Icons.science_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                appointment.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkBlue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isUpcoming
                                    ? AppTheme.primaryGreen.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isUpcoming
                                      ? AppTheme.primaryGreen
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                isUpcoming
                                    ? (loc?.translate('upcoming') ?? "Upcoming")
                                    : (loc?.translate('completed') ??
                                        "Completed"),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isUpcoming
                                      ? AppTheme.primaryGreen
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // DIVIDER
            Divider(height: 1, color: Colors.grey[100]),
            // BOTTOM SECTION: Date | Time | Fee
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildDetailItem(
                    Icons.calendar_today_rounded,
                    DateFormat('MMM d, yyyy').format(appointment.dateTime),
                    "Date",
                  ),
                  _buildVerticalDivider(),
                  _buildDetailItem(
                    Icons.access_time_rounded,
                    DateFormat('h:mm a').format(appointment.dateTime),
                    "Time",
                  ),
                  _buildVerticalDivider(),
                  _buildDetailItem(
                    Icons.currency_rupee_rounded,
                    appointment.fee,
                    "Total Fee",
                    isPrice: true,
                  ),
                ],
              ),
            ),
            // ACTION BUTTON (Only if upcoming)
            if (isUpcoming) ...[
              Divider(height: 1, color: Colors.grey[100]),
              InkWell(
                onTap: () => _cancelAppointment(appointment),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      loc?.translate('cancel_booking') ?? "Cancel Booking",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label,
      {bool isPrice = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isPrice ? "₹$value" : value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isPrice ? AppTheme.darkBlue : const Color(0xFF2C3E50),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
