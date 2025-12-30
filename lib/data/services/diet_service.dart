import 'package:dio/dio.dart';

import 'package:kayaone/core/api_config.dart';

class DietService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConfig.baseUrl}/diet',
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<Map<String, dynamic>?> getDietProfile(String userId) async {
    try {
      final response = await _dio.get('/$userId');
      if (response.data['success']) return response.data['diet'];
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile(String userId, Map<String, dynamic> metrics,
      Map<String, dynamic> goals) async {
    try {
      final response = await _dio.post('/update-profile', data: {
        'userId': userId,
        'metrics': metrics,
        'goals': goals,
      });
      return response.data['success'];
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> generatePlan(String userId) async {
    try {
      final response =
          await _dio.post('/generate-plan', data: {'userId': userId});
      if (response.data['success']) return response.data['plan'];
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> logCalories(String userId, int calories) async {
    try {
      final response = await _dio.post('/log-calories', data: {
        'userId': userId,
        'calories': calories,
      });
      if (response.data['success']) return response.data['eaten'];
      return null;
    } catch (e) {
      return null;
    }
  }
}
