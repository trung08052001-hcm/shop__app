import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';

abstract class CouponRemoteDataSource {
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double orderTotal,
  });
}

@Injectable(as: CouponRemoteDataSource)
class CouponRemoteDataSourceImpl implements CouponRemoteDataSource {
  final DioClient dioClient;
  CouponRemoteDataSourceImpl(this.dioClient);

  @override
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double orderTotal,
  }) async {
    try {
      final res = await dioClient.dio.post(
        '/coupons/validate',
        data: {'code': code, 'orderTotal': orderTotal},
      );
      return res.data;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data?['message'] ?? 'Mã giảm giá không hợp lệ',
      );
    }
  }
}
