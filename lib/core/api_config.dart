class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for Windows/Web,
  // or your local IP (e.g., 192.168.x.x) for physical devices.
  static const String baseUrl = 'https://medinest-4rg2.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
