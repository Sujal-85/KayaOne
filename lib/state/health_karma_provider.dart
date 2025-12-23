import 'package:flutter/material.dart';
import 'package:medinest/data/models/health_karma.dart';

class HealthKarmaProvider with ChangeNotifier {
  int _currentQuestionIndex = 0;
  final Map<String, dynamic> _userResponses = {};
  HealthKarmaResult? _result;
  bool _isLoading = false;

  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, dynamic> get userResponses => _userResponses;
  HealthKarmaResult? get result => _result;
  bool get isLoading => _isLoading;

  final List<HealthKarmaQuestion> questions = [
    HealthKarmaQuestion(
      id: "q1",
      title: "Tell us about your lifestyle",
      questionText: "Are you a vegetarian?",
      options: [
        "Non-veg (4–6 times/week)",
        "Occasional non-veg (1–3 times/week)",
        "Veg but no dairy",
        "Gluten-free diet",
        "Yes, vegetarian"
      ],
      illustrationPath: "assets/images/hk_q1_nutrition.png",
    ),
    HealthKarmaQuestion(
      id: "q2",
      title: "Tell us about your lifestyle",
      questionText:
          "How many days per week do you exercise for 30 minutes or more?",
      options: [
        "5 or more days",
        "3–4 days",
        "2 or fewer days",
        "No physical activity"
      ],
      illustrationPath: "assets/images/hk_q2_exercise.png",
    ),
    HealthKarmaQuestion(
      id: "q3",
      title: "Tell us about your lifestyle",
      questionText: "What is your age group?",
      options: ["Under 25", "25–35", "36–45", "46–60", "Above 60"],
      illustrationPath: "assets/images/hk_q3_age.png",
    ),
    HealthKarmaQuestion(
      id: "q4",
      title: "Tell us about your lifestyle",
      questionText: "How would you describe your body weight?",
      options: ["Underweight", "Normal", "Overweight", "Obese"],
      illustrationPath: "assets/images/hk_q4_weight.png",
    ),
    HealthKarmaQuestion(
      id: "q5",
      title: "Tell us about your lifestyle",
      questionText: "Do you smoke?",
      options: [
        "No, I don't smoke",
        "1–3 cigarettes/day",
        "5–10 cigarettes/day",
        "More than 10/day"
      ],
      illustrationPath: "assets/images/hk_q5_smoking.png",
    ),
    HealthKarmaQuestion(
      id: "q6",
      title: "Tell us about your lifestyle",
      questionText: "Do you consume alcohol?",
      options: ["Never", "Occasionally", "Weekly", "Frequently"],
      illustrationPath: "assets/images/hk_q6_alcohol.png",
    ),
    HealthKarmaQuestion(
      id: "q7",
      title: "Tell us about your lifestyle",
      questionText: "How would you rate your stress level?",
      options: ["Low", "Moderate", "High", "Very high"],
      illustrationPath: "assets/images/hk_q7_stress.png",
    ),
    HealthKarmaQuestion(
      id: "q8",
      title: "Tell us about your lifestyle",
      questionText: "How many hours do you sleep daily?",
      options: ["Less than 5", "5–6", "7–8", "More than 8"],
      illustrationPath: "assets/images/hk_q8_sleep.png",
    ),
    HealthKarmaQuestion(
      id: "q9",
      title: "Tell us about your lifestyle",
      questionText: "Do you have any existing medical conditions?",
      isMultiSelect: true,
      options: ["Diabetes", "Hypertension", "Thyroid", "Heart disease", "None"],
      illustrationPath: "assets/images/hk_q9_medical.png",
    ),
    HealthKarmaQuestion(
      id: "q10",
      title: "Tell us about your lifestyle",
      questionText: "Do you experience frequent urinary problems?",
      options: [
        "No",
        "Occasional urgency",
        "Frequent urgency & burning",
        "Increased urination with thirst"
      ],
      illustrationPath: "assets/images/hk_q10_urinary.png",
    ),
    HealthKarmaQuestion(
      id: "q11",
      title: "Tell us about your lifestyle",
      questionText: "How often do you eat outside / junk food?",
      options: ["Rarely", "1–2 times/week", "3–4 times/week", "Almost daily"],
      illustrationPath: "assets/images/hk_q11_junk.png",
    ),
    HealthKarmaQuestion(
      id: "q12",
      title: "Tell us about your lifestyle",
      questionText: "Do you have a family history of diseases?",
      isMultiSelect: true,
      options: [
        "Diabetes",
        "Hypertension",
        "Heart disease",
        "Cancer",
        "High cholesterol",
        "Kidney disease",
        "No"
      ],
      illustrationPath:
          "assets/images/logo_removebg.png", // Using branded logo as fallback for family tree
    ),
  ];

  void setResponse(String questionId, dynamic response) {
    _userResponses[questionId] = response;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void setResults(HealthKarmaResult result) {
    _result = result;
    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userResponses.clear();
    _result = null;
    _isLoading = false;
    notifyListeners();
  }
}
