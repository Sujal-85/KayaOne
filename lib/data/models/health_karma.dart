// No imports needed for basic POD models

class HealthKarmaQuestion {
  final String id;
  final String title;
  final String questionText;
  final List<String> options;
  final bool isMultiSelect;
  final String illustrationPath;

  HealthKarmaQuestion({
    required this.id,
    required this.title,
    required this.questionText,
    required this.options,
    this.isMultiSelect = false,
    required this.illustrationPath,
  });
}

class HealthKarmaResult {
  final int score;
  final Map<String, String> riskLevels; // e.g. {"cholesterol": "Medium"}
  final Map<String, List<String>> explanations;
  final List<String> suggestions;
  final DateTime date;

  HealthKarmaResult({
    required this.score,
    required this.riskLevels,
    required this.explanations,
    required this.suggestions,
    required this.date,
  });

  factory HealthKarmaResult.fromJson(Map<String, dynamic> json) {
    return HealthKarmaResult(
      score: json['score'] ?? 0,
      riskLevels: Map<String, String>.from(json['riskLevels'] ?? {}),
      explanations: (json['explanations'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ) ??
          {},
      suggestions: List<String>.from(json['suggestions'] ?? []),
      date: DateTime.now(),
    );
  }
}
