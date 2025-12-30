import 'package:dio/dio.dart';
import 'package:kayaone/core/api_config.dart';
import 'package:kayaone/data/models/health_karma.dart';
import 'package:flutter/foundation.dart';

class HealthKarmaService {
  final Dio _dio = Dio();

  Future<HealthKarmaResult> analyzeHealthData(
      Map<String, dynamic> responses) async {
    try {
      const String endpoint = '${ApiConfig.baseUrl}/ai/analyze';
      debugPrint("Calling HealthKarma Analysis Endpoint: $endpoint");
      debugPrint("Responses: $responses");

      final response = await _dio.post(
        endpoint,
        data: {
          'responses': responses,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("AI Analysis Result: $data");
        return HealthKarmaResult.fromJson(data);
      } else {
        String errorMessage = "Failed to analyze health data";
        try {
          // Try to parse the error message from the server
          if (response.data is Map && response.data['message'] != null) {
            errorMessage += ": ${response.data['message']}";
            if (response.data['error'] != null) {
              errorMessage += " (${response.data['error']})";
            }
          } else {
            errorMessage += ": Status ${response.statusCode}";
          }
        } catch (_) {
          errorMessage += ": Status ${response.statusCode} (Unknown error)";
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Error in analyzeHealthData: $e");
      // Fallback or rethrow
      throw Exception("Failed to analyze health data: $e");
    }
  }
}
