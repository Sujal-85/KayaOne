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
      throw Exception('Server error: ${response.statusMessage}');
    } on DioException catch (e) {
      print('Error uploading profile pic: ${e.message}');
      final data = e.response?.data;
      final msg = data is Map ? data['message'] : data;
      throw Exception('Upload failed: ${msg ?? e.message}');
    } catch (e) {
      print('Error uploading profile pic: $e');
      throw Exception('Upload failed: $e');
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
      throw Exception('Server error: ${response.statusMessage}');
    } on DioException catch (e) {
      print('Error uploading prescription: ${e.message}');
      final data = e.response?.data;
      final msg = data is Map ? data['message'] : data;
      throw Exception('Upload failed: ${msg ?? e.message}');
    } catch (e) {
      print('Error uploading prescription: $e');
      throw Exception('Upload failed: $e');
    }
  }
}
