import 'package:flutter/material.dart';

class BookingProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _selectedTests = [];
  String? _prescriptionPath;
  String? _selectedAddress;
  String? _selectedDate;
  String? _selectedSlot;

  // Patient Details (Auto-filled)
  String? _patientName;
  String? _patientPhone;

  final List<Map<String, String>> _savedAddresses = [];

  List<Map<String, dynamic>> get selectedTests => _selectedTests;
  String? get prescriptionPath => _prescriptionPath;
  String? get selectedAddress => _selectedAddress;
  String? get selectedDate => _selectedDate;
  String? get selectedSlot => _selectedSlot;
  String? get patientName => _patientName;
  String? get patientPhone => _patientPhone;
  List<Map<String, String>> get savedAddresses => _savedAddresses;

  void addSavedAddress(Map<String, String> address) {
    _savedAddresses.add(address);
    notifyListeners();
  }

  void removeSavedAddress(int index) {
    _savedAddresses.removeAt(index);
    notifyListeners();
  }

  void setPatientDetails(String name, String phone) {
    _patientName = name;
    _patientPhone = phone;
    notifyListeners();
  }

  void addTest(Map<String, dynamic> test) {
    _selectedTests.add(test);
    notifyListeners();
  }

  void removeTest(int index) {
    _selectedTests.removeAt(index);
    notifyListeners();
  }

  void setPrescription(String? path) {
    _prescriptionPath = path;
    notifyListeners();
  }

  void setAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void setDateTime(String date, String slot) {
    _selectedDate = date;
    _selectedSlot = slot;
    notifyListeners();
  }

  void clear() {
    _selectedTests.clear();
    _prescriptionPath = null;
    _selectedAddress = null;
    _selectedDate = null;
    _selectedSlot = null;
    notifyListeners();
  }
}
