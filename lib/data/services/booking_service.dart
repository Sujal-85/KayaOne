import 'package:dio/dio.dart';
import 'package:medinest/state/booking_provider.dart';

import 'package:medinest/core/api_config.dart';

class BookingService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConfig.baseUrl}/booking',
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<bool> createBooking(String userId, BookingProvider provider) async {
    try {
      final total = provider.selectedTests
          .fold<int>(0, (sum, item) => sum + (item['price'] as int));

      final response = await _dio.post('/create', data: {
        'userId': userId,
        'patientName': provider.patientName,
        'patientPhone': provider.patientPhone,
        'tests': provider.selectedTests,
        'prescriptionPath': provider.prescriptionPath,
        'address': provider.selectedAddress,
        'date': provider.selectedDate,
        'slot': provider.selectedSlot,
        'totalAmount': total + 99 - 50, // subtotal + fee - discount
      });

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating booking: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getUserBookings(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      if (response.data['success']) {
        return response.data['bookings'];
      }
      return null;
    } catch (e) {
      print('Error fetching bookings: $e');
      return null;
    }
  }
}
