import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider extends ChangeNotifier {
  String _currentAddress = "Fetching Location...";
  bool _isLoading = true;
  String? _error;

  String get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  LocationProvider() {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled.';
        _currentAddress = "Location Disabled";
        _isLoading = false;
        notifyListeners();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          _currentAddress = "Permission Denied";
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error =
            'Location permissions are permanently denied, we cannot request permissions.';
        _currentAddress = "Permission Denied";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      Position position = await Geolocator.getCurrentPosition();

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          // Format: "Locality, Country" or "SubLocality, Locality"
          String locality = place.locality ?? "";
          String subLocality = place.subLocality ?? "";
          String country = place.country ?? "";

          if (locality.isNotEmpty && country.isNotEmpty) {
            _currentAddress = "$locality, $country";
          } else if (subLocality.isNotEmpty && locality.isNotEmpty) {
            _currentAddress = "$subLocality, $locality";
          } else {
            _currentAddress =
                locality.isNotEmpty ? locality : "Unknown Location";
          }
        } else {
          _currentAddress = "Unknown Location";
        }
      } catch (e) {
        debugPrint("Error decoding address: $e");
        _currentAddress = "Unknown Location";
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error getting location: $e");
      _error = e.toString();
      _currentAddress = "Error fetching location";
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLocation() async {
    _isLoading = true;
    notifyListeners();
    await _getCurrentLocation();
  }
}
