import 'package:dio/dio.dart';

import 'package:medinest/core/api_config.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<Map<String, dynamic>?> login(String phoneNumber) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'phoneNumber': phoneNumber,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile({
    required String phoneNumber,
    required String name,
    required String dob,
    required String email,
    required String city,
    String? profilePic,
  }) async {
    try {
      final data = {
        'phoneNumber': phoneNumber,
        'name': name,
        'dob': dob,
        'email': email,
        'city': city,
      };
      if (profilePic != null) data['profilePic'] = profilePic;

      final response = await _dio.post('/auth/update-profile', data: data);
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String phoneNumber) async {
    try {
      final response = await _dio.get('/auth/profile/$phoneNumber');
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
