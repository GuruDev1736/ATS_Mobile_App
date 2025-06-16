import 'package:ata_mobile/Utilities/SharedPrefManager.dart';
import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.0.112:8081/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    // Add Authorization Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip token for login or public routes
          if (options.path.contains('/auth/login') ||
              options.path.contains('/auth/sendOTP') ||
              options.path.contains('/auth/verifyOTP') ||
              options.path.contains('/auth/resetPassword') ||
              options.path.contains('/public')) {
            return handler.next(options);
          }

          // Get token from SharedPrefManager
          final sharedPref = SharedPrefManager();
          final token = await sharedPref.getString(
            SharedPrefManager.userTokenKey,
          );

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = token;
            print("🔐 Auth Token Added: $token");
          } else {
            print("⚠️ No Auth Token Found");
          }

          return handler.next(options);
        },
      ),
    );
  }
}
