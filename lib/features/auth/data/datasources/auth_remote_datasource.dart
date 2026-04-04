import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String address,
    required String phone,
  });
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;
  final SharedPreferences prefs;

  const AuthRemoteDataSourceImpl(this.dioClient, this.prefs);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await dioClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      await prefs.setString('access_token', res.data['token']);
      return UserModel.fromJson(res.data['user']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Đăng nhập thất bại',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Lấy thông tin người dùng hiện tại
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final res = await dioClient.dio.get('/auth/me');
      return UserModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Lỗi tải thông tin',
      );
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String address,
    required String phone,
  }) async {
    try {
      final res = await dioClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'phone': phone,
        },
      );
      await prefs.setString('access_token', res.data['token']);
      return UserModel.fromJson(res.data['user']);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Đăng ký thất bại',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    await prefs.remove('access_token');
  }
}
