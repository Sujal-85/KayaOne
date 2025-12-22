import 'package:flutter/material.dart';

class DoctorProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'Dr. Sarah Wilson',
      'specialty': 'Cardiologist',
      'experience': '12 years',
      'rating': 4.9,
      'reviews': 120,
      'fee': 800,
      'image':
          'https://img.freepik.com/free-photo/stethoscopes-doctors-hospital_23-2149351000.jpg', // Placeholder
    },
    {
      'id': '2',
      'name': 'Dr. James Miller',
      'specialty': 'Dermatologist',
      'experience': '8 years',
      'rating': 4.7,
      'reviews': 85,
      'fee': 600,
      'image':
          'https://img.freepik.com/free-photo/close-up-doctor-filling-out-medical-form_23-2149302636.jpg', // Placeholder
    },
  ];

  Map<String, dynamic>? _selectedDoctor;

  List<Map<String, dynamic>> get doctors => _doctors;
  Map<String, dynamic>? get selectedDoctor => _selectedDoctor;

  void selectDoctor(Map<String, dynamic> doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }
}
