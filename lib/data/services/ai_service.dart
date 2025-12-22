import 'package:dio/dio.dart';

import 'package:medinest/core/api_config.dart';

class AiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConfig.baseUrl}/ai',
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<String?> getAiReply(
      String message, List<Map<String, String>> history) async {
    try {
      final response = await _dio.post('/chat', data: {
        'message': message,
        'history': history,
      });

      if (response.data['success']) {
        return response.data['reply'];
      }
      return "I'm sorry, I couldn't process that request.";
    } catch (e) {
      print('AI Service Error: $e');
      return "Connection error. Please check if the server is running and your API key is valid.";
    }
  }
}
