import 'package:dio/dio.dart';
import 'package:medinest/core/api_config.dart';
import 'package:medinest/data/models/health_karma.dart';
import 'package:flutter/foundation.dart';

class HealthKarmaService {
  final Dio _dio = Dio();

  Future<HealthKarmaResult> analyzeHealthData(
      Map<String, dynamic> responses) async {
    try {
      final String endpoint = '${ApiConfig.baseUrl}/ai/analyze';
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
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("AI Analysis Result: $data");
        return HealthKarmaResult.fromJson(data);
      } else {
        throw Exception(
            "Failed to analyze health data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in analyzeHealthData: $e");
      // Fallback or rethrow
      throw Exception("Failed to analyze health data: $e");
    }
  }
}
