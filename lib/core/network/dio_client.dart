import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../error/exceptions.dart';

final String _baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000/api';

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
      _AuthInterceptor(_dio),
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
  final Dio dio;

  _AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && 
        err.requestOptions.path != '/auth/refresh' && 
        err.requestOptions.path != '/auth/login') {
      
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
          final res = await refreshDio.post('/auth/refresh', data: {
            'refreshToken': refreshToken
          });
          
          final newAccessToken = res.data['token'];
          final newRefreshToken = res.data['refreshToken'];
          
          await prefs.setString('access_token', newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString('refresh_token', newRefreshToken);
          }
          
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final cloneReq = await dio.fetch(err.requestOptions);
          return handler.resolve(cloneReq);
        } catch (e) {
          await prefs.remove('access_token');
          await prefs.remove('refresh_token');
          throw UnauthorizedException();
        }
      } else {
        throw UnauthorizedException();
      }
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw NetworkException();
      default:
        if (err.response?.statusCode == 401) {
          throw UnauthorizedException();
        }
        throw ServerException(
          err.response?.data?['message'] ?? 'Lỗi server',
          statusCode: err.response?.statusCode,
        );
    }
  }
}
