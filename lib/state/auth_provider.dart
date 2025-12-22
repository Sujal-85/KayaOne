import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isProfileComplete = false;
  String? _userId;
  String? _phoneNumber;
  String? _userName;
  String? _email;
  String? _profilePic;
  String? _city;
  String? _dob;

  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileComplete => _isProfileComplete;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  String? get userName => _userName;
  String? get email => _email;
  String? get profilePic => _profilePic;
  String? get city => _city;
  String? get dob => _dob;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
    _userId = prefs.getString('userId');
    _phoneNumber = prefs.getString('phoneNumber');
    _userName = prefs.getString('userName');
    _email = prefs.getString('email');
    _profilePic = prefs.getString('profilePic');
    _city = prefs.getString('city');
    _dob = prefs.getString('dob');
    notifyListeners();
  }

  void login(String phone,
      {String? userId,
      String? name,
      String? email,
      String? profilePic,
      String? city,
      String? dob,
      bool isProfileComplete = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _isProfileComplete = isProfileComplete;
    _userId = userId;
    _phoneNumber = phone;
    _userName = name;
    _email = email;
    _profilePic = profilePic;
    _city = city;
    _dob = dob;

    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isProfileComplete', isProfileComplete);
    if (userId != null) await prefs.setString('userId', userId);
    await prefs.setString('phoneNumber', phone);
    if (name != null) await prefs.setString('userName', name);
    if (email != null) await prefs.setString('email', email);
    if (profilePic != null) await prefs.setString('profilePic', profilePic);
    if (city != null) await prefs.setString('city', city);
    if (dob != null) await prefs.setString('dob', dob);

    notifyListeners();
  }

  void completeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isProfileComplete = true;
    await prefs.setBool('isProfileComplete', true);
    notifyListeners();
  }

  void updateUserInfo(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = name;
    await prefs.setString('userName', name);
    notifyListeners();
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _isProfileComplete = false;
    _phoneNumber = null;
    _userName = null;

    await prefs.clear();
    notifyListeners();
  }
}
