import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kayaone/core/localization/app_localizations.dart';
import 'package:kayaone/core/theme/app_theme.dart';
import 'package:kayaone/state/booking_provider.dart';
import 'package:kayaone/presentation/prescription/prescription_upload_screen.dart';

class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({super.key});

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen> {
  // Localization logic for static data will be handled in build
  final List<Map<String, dynamic>> _allTests = [
    {
      'id': '1',
      'name': 'Complete Blood Count (CBC)',
      'key_name': 'test_cbc',
      'key_desc': 'test_cbc_desc',
      'price': 399,
      'desc': 'Includes 24 parameters',
      'category': 'General'
    },
    {
      'id': '2',
      'name': 'Thyroid Profile (T3, T4, TSH)',
      'key_name': 'test_thyroid',
      'key_desc': 'test_thyroid_desc',
      'price': 599,
      'desc': 'Check your thyroid function',
      'category': 'Hormonal'
    },
    {
      'id': '3',
      'name': 'Diabetes Screening (HbA1c)',
      'key_name': 'test_diabetes',
      'key_desc': 'test_diabetes_desc',
      'price': 449,
      'desc': 'Average blood sugar levels',
      'category': 'General'
    },
    {
      'id': '4',
      'name': 'Lipid Profile',
      'key_name': 'test_lipid',
      'key_desc': 'test_lipid_desc',
      'price': 799,
      'desc': 'Cholesterol and triglycerides',
      'category': 'Hormonal'
    },
    {
      'id': '5',
      'name': 'Vitamin B12',
      'key_name': 'test_vitamin',
      'key_desc': 'test_vitamin_desc',
      'price': 899,
      'desc': 'Check for B12 deficiency',
      'category': 'Vitamins'
    },
    {
      'id': '6',
      'name': 'Full Body Checkup',
      'key_name': 'test_fullbody',
      'key_desc': 'test_fullbody_desc',
      'price': 1999,
      'desc': '60+ comprehensive tests',
      'category': 'Packages'
    },
  ];

  String _searchQuery = "";

  String _getLocalizedName(AppLocalizations? loc, Map<String, dynamic> test) {
    if (test.containsKey('key_name') && loc != null) {
      return loc.translate(test['key_name']!);
    }
    return test['name'];
  }

  String _getLocalizedDesc(AppLocalizations? loc, Map<String, dynamic> test) {
    if (test.containsKey('key_desc') && loc != null) {
      return loc.translate(test['key_desc']!);
    }
    return test['desc'];
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final loc = AppLocalizations.of(context);

    final filteredTests = _allTests.where((test) {
      final name = _getLocalizedName(loc, test);
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc?.translate('book_blood_test') ?? 'Book Blood Test'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined)),
              if (bookingProvider.selectedTests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      bookingProvider.selectedTests.length.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: loc?.translate('search_tests_hint') ??
                    "Search tests or packages...",
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTests.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final test = filteredTests[index];
                bool isAdded = bookingProvider.selectedTests
                    .any((t) => t['id'] == test['id']);

                final localizedName = _getLocalizedName(loc, test);
                final localizedDesc = _getLocalizedDesc(loc, test);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(localizedName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(localizedDesc,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text("₹${test['price']}",
                                  style: const TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (isAdded) {
                              int idx = bookingProvider.selectedTests
                                  .indexWhere((t) => t['id'] == test['id']);
                              bookingProvider.removeTest(idx);
                            } else {
                              bookingProvider.addTest(test);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isAdded ? Colors.grey : AppTheme.secondaryColor,
                            minimumSize: const Size(80, 40),
                          ),
                          child: Text(isAdded
                              ? (loc?.translate('added') ?? "Added")
                              : (loc?.translate('add') ?? "Add")),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (bookingProvider.selectedTests.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "${bookingProvider.selectedTests.length} ${loc?.translate('items_added') ?? 'Items Added'}",
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                        Text(
                          "${loc?.translate('total') ?? 'Total'}: ₹${bookingProvider.selectedTests.fold<int>(0, (sum, item) => sum + (item['price'] as int))}",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppTheme.darkBlue),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PrescriptionUploadScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        minimumSize: const Size(140, 54),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Text(loc?.translate('continue') ?? "Continue",
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 18, color: Colors.white),
                        ],
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
}
