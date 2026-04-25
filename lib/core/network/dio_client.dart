import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


const _baseUrl =
    'http://192.168.1.29:3000/api'; // IP máy tính cho máy thật (cùng Wi-Fi)
// const _baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator

@singleton
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    // Không gửi token cho các API đăng nhập, đăng ký
    final isAuthRoute = options.path.contains('/auth/login') || options.path.contains('/auth/register');
    
    if (token != null && !isAuthRoute) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

}
