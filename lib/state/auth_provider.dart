import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGuest = false;
  bool _isProfileComplete = false;
  bool _isOnboardingComplete = false;
  String? _userId;
  String? _phoneNumber;
  String? _userName;
  String? _email;
  String? _profilePic;
  String? _city;
  String? _dob;
  String? _bloodGroup;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  bool get isProfileComplete => _isProfileComplete;
  bool get isOnboardingComplete => _isOnboardingComplete;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  String? get userName => _userName;
  String? get email => _email;
  String? get profilePic => _profilePic;
  String? get city => _city;
  String? get dob => _dob;
  String? get bloodGroup => _bloodGroup;

  AuthProvider() {
    _loadSession();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isProfileComplete = prefs.getBool('isProfileComplete') ?? false;
    _isOnboardingComplete = prefs.getBool('isOnboardingComplete') ?? false;
    _userId = prefs.getString('userId');
    _phoneNumber = prefs.getString('phoneNumber');
    _userName = prefs.getString('userName');
    _email = prefs.getString('email');
    _profilePic = prefs.getString('profilePic');
    _city = prefs.getString('city');
    _dob = prefs.getString('dob');
    _bloodGroup = prefs.getString('bloodGroup');
    _isLoading = false;
    notifyListeners();
  }

  void login(String phone,
      {String? userId,
      String? name,
      String? email,
      String? profilePic,
      String? city,
      String? dob,
      String? bloodGroup,
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
    _bloodGroup = bloodGroup;

    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isProfileComplete', isProfileComplete);
    if (userId != null) await prefs.setString('userId', userId);
    await prefs.setString('phoneNumber', phone);
    if (name != null) await prefs.setString('userName', name);
    if (email != null) await prefs.setString('email', email);
    if (profilePic != null) await prefs.setString('profilePic', profilePic);
    if (city != null) await prefs.setString('city', city);
    if (dob != null) await prefs.setString('dob', dob);
    if (bloodGroup != null) await prefs.setString('bloodGroup', bloodGroup);

    notifyListeners();
  }

  void completeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _isProfileComplete = true;
    await prefs.setBool('isProfileComplete', true);
    notifyListeners();
  }

  void completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingComplete = true;
    await prefs.setBool('isOnboardingComplete', true);
    notifyListeners();
  }

  void updateUserInfo({
    required String name,
    String? email,
    String? city,
    String? dob,
    String? bloodGroup,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = name;
    await prefs.setString('userName', name);

    if (email != null) {
      _email = email;
      await prefs.setString('email', email);
    }
    if (city != null) {
      _city = city;
      await prefs.setString('city', city);
    }
    if (dob != null) {
      _dob = dob;
      await prefs.setString('dob', dob);
    }
    if (bloodGroup != null) {
      _bloodGroup = bloodGroup;
      await prefs.setString('bloodGroup', bloodGroup);
    }

    notifyListeners();
  }

  void updateProfilePic(String url) async {
    if (url.isEmpty || !url.startsWith('http')) return;

    final prefs = await SharedPreferences.getInstance();
    _profilePic = url;
    await prefs.setString('profilePic', url);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _isGuest = false;
    _isProfileComplete = false;
    _phoneNumber = null;
    _userName = null;

    await prefs.clear();
    notifyListeners();
  }

  void loginAsGuest() {
    _isGuest = true;
    _isLoggedIn = true;
    notifyListeners();
  }
}
