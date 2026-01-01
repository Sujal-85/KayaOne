import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kayaone/core/api_config.dart';

class StorageService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<String?> uploadProfilePic(String phoneNumber, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'phoneNumber': phoneNumber,
        'avatar': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('/auth/update-avatar', data: formData);

      if (response.statusCode == 200) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading profile pic: $e');
      return null;
    }
  }

  Future<String?> uploadPrescription(String userId, File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'prescription':
            await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/booking/upload-prescription',
        data: formData,
        options: Options(
            contentType: 'multipart/form-data'), // Explicitly set content type
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading prescription: $e');
      return null;
    }
  }
}
