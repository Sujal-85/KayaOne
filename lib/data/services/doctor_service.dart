import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:kayaone/core/api_config.dart';

class DoctorService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConfig.baseUrl}/doctor',
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<bool> bookAppointment({
    required String userId,
    required String doctorId,
    required String doctorName,
    required DateTime date,
    required String slot,
    required int fee,
  }) async {
    try {
      final response = await _dio.post('/book', data: {
        'userId': userId,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'appointmentDate': DateFormat('yyyy-MM-dd').format(date),
        'appointmentSlot': slot,
        'fee': fee,
      });

      return response.statusCode == 201;
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getUserAppointments(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      if (response.data['success']) {
        return response.data['bookings'];
      }
      return null;
    } catch (e) {
      print('Error fetching appointments: $e');
      return null;
    }
  }
}
