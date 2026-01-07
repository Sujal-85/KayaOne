import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _selectedTests = [];
  String? _prescriptionPath;
  String? _selectedAddress;
  String? _selectedDate;
  String? _selectedSlot;

  // Patient Details (Auto-filled)
  String? _patientName;
  String? _patientPhone;

  List<Map<String, String>> _savedAddresses = [];

  BookingProvider() {
    _loadSavedAddresses();
  }

  List<Map<String, dynamic>> get selectedTests => _selectedTests;
  String? get prescriptionPath => _prescriptionPath;
  String? get selectedAddress => _selectedAddress;
  String? get selectedDate => _selectedDate;
  String? get selectedSlot => _selectedSlot;
  String? get patientName => _patientName;
  String? get patientPhone => _patientPhone;
  List<Map<String, String>> get savedAddresses => _savedAddresses;

  Future<void> _loadSavedAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedAddresses = prefs.getString('saved_addresses');
    if (storedAddresses != null) {
      final List<dynamic> decoded = jsonDecode(storedAddresses);
      _savedAddresses =
          decoded.map((e) => Map<String, String>.from(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_savedAddresses);
    await prefs.setString('saved_addresses', encoded);
  }

  void addSavedAddress(Map<String, String> address) {
    _savedAddresses.add(address);
    _saveAddresses();
    notifyListeners();
  }

  void removeSavedAddress(int index) {
    _savedAddresses.removeAt(index);
    _saveAddresses();
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
