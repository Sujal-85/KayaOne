import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:medinest/core/theme/app_theme.dart';
import 'package:medinest/state/booking_provider.dart';
import 'package:medinest/presentation/booking/time_slot_screen.dart';
import 'package:medinest/presentation/booking/widgets/booking_step_indicator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int _selectedAddressIndex = 0;
  bool _isDetectingLocation = false;

  Future<void> _getCurrentLocation(
      Function(String house, String area, String landmark, String city,
              String pincode)
          onLocationDetected) async {
    setState(() => _isDetectingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        onLocationDetected(
          place.name ?? '',
          place.subLocality ?? place.locality ?? '',
          place.street ?? '',
          place.locality ?? '',
          place.postalCode ?? '',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isDetectingLocation = false);
    }
  }

  Future<void> _showAddAddressDialog(BookingProvider provider) async {
    final houseController = TextEditingController();
    final areaController = TextEditingController();
    final landmarkController = TextEditingController();
    final cityController = TextEditingController();
    final pincodeController = TextEditingController();
    String selectedType = 'Home';

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Add New Address",
                        style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await _getCurrentLocation(
                        (house, area, landmark, city, pincode) {
                      setDialogState(() {
                        houseController.text = house;
                        areaController.text = area;
                        landmarkController.text = landmark;
                        cityController.text = city;
                        pincodeController.text = pincode;
                      });
                    });
                  },
                  icon: const Icon(Icons.my_location_rounded,
                      color: AppTheme.primaryGreen),
                  label: Text("Use Current Location",
                      style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAddressField("Address Type",
                    items: ['Home', 'Office', 'Other'],
                    initialValue: selectedType, onChanged: (val) {
                  setDialogState(() => selectedType = val!);
                }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _buildAddressField("House/Flat/Floor",
                            controller: houseController)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildAddressField("Pincode",
                            controller: pincodeController,
                            keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAddressField("Area/Street/Locality",
                    controller: areaController),
                const SizedBox(height: 12),
                _buildAddressField("Landmark (Optional)",
                    controller: landmarkController),
                const SizedBox(height: 12),
                _buildAddressField("City", controller: cityController),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (houseController.text.isNotEmpty &&
                          areaController.text.isNotEmpty &&
                          cityController.text.isNotEmpty) {
                        final fullAddress =
                            "${houseController.text}, ${landmarkController.text.isNotEmpty ? landmarkController.text + ', ' : ''}${areaController.text}, ${cityController.text} - ${pincodeController.text}";
                        provider.addSavedAddress({
                          'type': selectedType,
                          'address': fullAddress,
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text("Save Address",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressField(String label,
      {TextEditingController? controller,
      List<String>? items,
      String? initialValue,
      Function(String?)? onChanged,
      TextInputType keyboardType = TextInputType.text}) {
    if (items != null) {
      return DropdownButtonFormField<String>(
        value: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        items: items
            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
            .toList(),
        onChanged: onChanged,
      );
    }
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text("Collection Address",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BookingStepIndicator(currentStep: 1),
              const SizedBox(height: 16),
              Text(
                "Where should we collect\nyour sample?",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkBlue,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              if (bookingProvider.savedAddresses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.location_off_rounded,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No saved addresses yet",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookingProvider.savedAddresses.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedAddressIndex == index;
                    final address = bookingProvider.savedAddresses[index];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedAddressIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryGreen.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                address['type'] == 'Home'
                                    ? Icons.home_rounded
                                    : address['type'] == 'Office'
                                        ? Icons.work_rounded
                                        : Icons.location_on_rounded,
                                color: isSelected
                                    ? AppTheme.primaryGreen
                                    : Colors.grey,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(address['type']!,
                                      style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: AppTheme.darkBlue)),
                                  const SizedBox(height: 4),
                                  Text(address['address']!,
                                      style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppTheme.primaryGreen),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              OutlinedButton.icon(
                onPressed: () => _showAddAddressDialog(bookingProvider),
                icon: const Icon(Icons.add_location_alt_rounded, size: 20),
                label: Text("Add New Address",
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: AppTheme.darkBlue,
                  side: BorderSide(color: AppTheme.darkBlue.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: bookingProvider.savedAddresses.isEmpty
                    ? null
                    : () {
                        bookingProvider.setAddress(bookingProvider
                            .savedAddresses[_selectedAddressIndex]['address']!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const TimeSlotScreen()),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkBlue,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Proceed to Schedule",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
