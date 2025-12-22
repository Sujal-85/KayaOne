import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/doctor_provider.dart';
import 'package:medinest/presentation/doctors/doctor_profile_screen.dart';

class DoctorListingScreen extends StatefulWidget {
  const DoctorListingScreen({super.key});

  @override
  State<DoctorListingScreen> createState() => _DoctorListingScreenState();
}

class _DoctorListingScreenState extends State<DoctorListingScreen> {
  String _selectedSpecialty = "All";
  final List<String> _specialties = [
    "All",
    "Cardiology",
    "Dermatology",
    "Neurology",
    "Pediatrics"
  ];

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final doctors = doctorProvider.doctors.where((doc) {
      if (_selectedSpecialty == "All") return true;
      return doc['specialty'] == _selectedSpecialty;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Find Your Specialist",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        hintText: "Search doctors, specialties...",
                        hintStyle:
                            GoogleFonts.plusJakartaSans(color: Colors.grey),
                        icon: const Icon(Icons.search_rounded,
                            color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specialty Filter
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _specialties.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            _selectedSpecialty == _specialties[index];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedSpecialty = _specialties[index]),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.grey.shade100),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _specialties[index],
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.darkBlue,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
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
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final doctor = doctors[index];
                  return GestureDetector(
                    onTap: () {
                      doctorProvider.selectDoctor(doctor);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DoctorProfileScreen()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: 'doctor_${doctor['id']}',
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(doctor['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'],
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: AppTheme.darkBlue,
                                  ),
                                ),
                                Text(
                                  doctor['specialty'],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: Colors.orange, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${doctor['rating']} (${doctor['reviews']} Reviews)",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Fee",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10, color: Colors.grey),
                              ),
                              Text(
                                "₹${doctor['fee']}",
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: AppTheme.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: doctors.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
