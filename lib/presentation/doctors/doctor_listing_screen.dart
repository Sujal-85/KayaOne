import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/doctor_provider.dart';
import 'package:kayaone/presentation/doctors/doctor_profile_screen.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class DoctorListingScreen extends StatefulWidget {
  const DoctorListingScreen({super.key});

  @override
  State<DoctorListingScreen> createState() => _DoctorListingScreenState();
}

class _DoctorListingScreenState extends State<DoctorListingScreen> {
  bool _isLoading = true;
  String _selectedSpecialty = "All";
  final List<String> _specialties = [
    "All",
    "Cardiology",
    "Dermatology",
    "Neurology",
    "Pediatrics"
  ];

  @override
  void initState() {
    super.initState();
    // Simulate network delay for smooth transition
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  String _getLocalizedSpecialty(BuildContext context, String specialty) {
    var appLocalizations = AppLocalizations.of(context);
    switch (specialty) {
      case "All":
        return appLocalizations?.translate('specialty_all') ?? "All";
      case "Cardiology":
        return appLocalizations?.translate('specialty_cardiology') ??
            "Cardiology";
      case "Dermatology":
        return appLocalizations?.translate('specialty_dermatology') ??
            "Dermatology";
      case "Neurology":
        return appLocalizations?.translate('specialty_neurology') ??
            "Neurology";
      case "Pediatrics":
        return appLocalizations?.translate('specialty_pediatrics') ??
            "Pediatrics";
      default:
        // Try to translate if key matches lowercase specialty, otherwise return as is
        return appLocalizations
                ?.translate('specialty_${specialty.toLowerCase()}') ??
            specialty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    var appLocalizations = AppLocalizations.of(context);
    final doctors = doctorProvider.doctors.where((doc) {
      if (_selectedSpecialty == "All") return true;
      return doc['specialty'] == _selectedSpecialty;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home_bg_leaves.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
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
                child: RefreshIndicator(
                  color: AppTheme.primaryGreen,
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 140,
                        floating: true,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            appLocalizations?.translate('find_specialist') ??
                                "Find Your Specialist",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                          titlePadding:
                              const EdgeInsets.only(left: 56, bottom: 16),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LayoutBuilder(builder: (context, constraints) {
                          final isSmall = constraints.maxWidth < 400 ||
                              constraints.maxHeight < 700;
                          final searchPadding = isSmall ? 12.0 : 16.0;
                          final chipHeight = isSmall ? 36.0 : 44.0;
                          final chipPadding = isSmall ? 12.0 : 20.0;
                          final chipFontSize = isSmall ? 11.0 : 13.0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Search Bar
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: searchPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 10)
                                    ],
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: appLocalizations?.translate(
                                              'search_doctors_hint') ??
                                          "Search doctors...",
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey,
                                          fontSize: isSmall ? 13 : null),
                                      icon: const Icon(Icons.search_rounded,
                                          color: AppTheme.primaryGreen),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: isSmall ? 8 : 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Specialty Filter
                                SizedBox(
                                  height: chipHeight,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _specialties.length,
                                    itemBuilder: (context, index) {
                                      bool isSelected = _selectedSpecialty ==
                                          _specialties[index];
                                      return GestureDetector(
                                        onTap: () => setState(() =>
                                            _selectedSpecialty =
                                                _specialties[index]),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: chipPadding),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppTheme.primaryGreen
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: isSelected
                                                    ? Colors.transparent
                                                    : Colors.grey.shade100),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getLocalizedSpecialty(
                                                context, _specialties[index]),
                                            style: GoogleFonts.plusJakartaSans(
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme.darkBlue,
                                              fontWeight: FontWeight.w700,
                                              fontSize: chipFontSize,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          );
                        }),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (_isLoading) {
                                return _buildShimmerLoading();
                              }
                              if (doctors.isEmpty) {
                                return Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 40),
                                      Lottie.asset(
                                          'assets/lottie/No Data Animation.json',
                                          width: 250,
                                          height: 250),
                                      const SizedBox(height: 40),
                                      Text(
                                        "No doctors found",
                                        style: GoogleFonts.outfit(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.darkBlue),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final doctor = doctors[index];
                              return GestureDetector(
                                onTap: () {
                                  doctorProvider.selectDoctor(doctor);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const DoctorProfileScreen()),
                                  );
                                },
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  final isSmall = constraints.maxWidth < 360;
                                  final imageSize = isSmall ? 60.0 : 80.0;
                                  final padding = isSmall ? 10.0 : 16.0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: EdgeInsets.all(padding),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.02),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4))
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: 'doctor_${doctor['id']}',
                                          child: Container(
                                            width: imageSize,
                                            height: imageSize,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    doctor['image']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: isSmall ? 12 : 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor['name'],
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: isSmall ? 15 : 16,
                                                  color: AppTheme.darkBlue,
                                                ),
                                              ),
                                              Text(
                                                _getLocalizedSpecialty(context,
                                                    doctor['specialty']),
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  color: AppTheme.primaryGreen,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: isSmall ? 11 : 12,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded,
                                                      color: Colors.orange,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      "${doctor['rating']} (${doctor['reviews']} ${appLocalizations?.translate('reviews') ?? 'Reviews'})",
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              appLocalizations
                                                      ?.translate('fee') ??
                                                  "Fee",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "₹${doctor['fee']}",
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w900,
                                                fontSize: isSmall ? 16 : 18,
                                                color: AppTheme.primaryGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
                            childCount: _isLoading
                                ? 5
                                : (doctors.isEmpty ? 1 : doctors.length),
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

  Widget _buildShimmerLoading() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
