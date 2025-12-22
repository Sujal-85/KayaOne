import 'package:flutter/material.dart';
import 'package:medinest/data/services/diet_service.dart';

class DietProvider with ChangeNotifier {
  final DietService _dietService = DietService();

  Map<String, dynamic>? _dietData;
  bool _isLoading = false;

  Map<String, dynamic>? get dietData => _dietData;
  bool get isLoading => _isLoading;

  // New Profile Metrics (Temp state during creation)
  double weight = 70.0;
  int heightFeet = 5;
  int heightInches = 8;
  String selectedRegion = "India";
  List<String> medicalConditions = [];

  // Goals (Temp state during creation)
  String weightGoal = "Maintain Weight";
  String foodChoice = "Non Vegetarian";
  String activityLevel = "Moderate";

  Future<void> fetchDietProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dietData = await _dietService.getDietProfile(userId);
    } catch (e) {
      debugPrint("DietProvider Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _dietService.updateProfile(
      userId,
      {
        'weight': weight,
        'feet': heightFeet,
        'inches': heightInches,
        'region': selectedRegion,
        'medicalConditions': medicalConditions,
      },
      {
        'weightManagement': weightGoal,
        'foodChoice': foodChoice,
        'activityLevel': activityLevel,
      },
    );

    if (success) await fetchDietProfile(userId);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> generateNewPlan(String userId) async {
    _isLoading = true;
    notifyListeners();

    final plan = await _dietService.generatePlan(userId);
    if (plan != null) {
      await fetchDietProfile(userId); // Refresh data with new plan
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCalories(String userId, int cal) async {
    final newTotal = await _dietService.logCalories(userId, cal);
    if (newTotal != null) {
      if (_dietData != null) {
        _dietData!['tracking']['dailyCaloriesEaten'] = newTotal;
        notifyListeners();
      }
    }
  }

  void updateMetrics({double? w, int? ft, int? inc, String? reg}) {
    if (w != null) weight = w;
    if (ft != null) heightFeet = ft;
    if (inc != null) heightInches = inc;
    if (reg != null) selectedRegion = reg;
    notifyListeners();
  }

  void updateGoals({String? wg, String? fc, String? al}) {
    if (wg != null) weightGoal = wg;
    if (fc != null) foodChoice = fc;
    if (al != null) activityLevel = al;
    notifyListeners();
  }
}
