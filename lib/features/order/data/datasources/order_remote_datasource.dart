import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../../domain/entities/order.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required List<OrderItem> items,
    required double totalPrice,
  });
  Future<List<OrderModel>> getMyOrders();
}

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;
  OrderRemoteDataSourceImpl(this.dioClient);

  @override
  Future<OrderModel> createOrder({
    required List<OrderItem> items,
    required double totalPrice,
  }) async {
    try {
      final res = await dioClient.dio.post(
        '/orders',
        data: {
          'items': items
              .map(
                (e) => {
                  'product': e.productId,
                  'name': e.name,
                  'image': e.image,
                  'price': e.price,
                  'quantity': e.quantity,
                },
              )
              .toList(),
          'totalPrice': totalPrice,
        },
      );
      return OrderModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi tạo đơn hàng');
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final res = await dioClient.dio.get('/orders');
      final data = res.data;
      if (data is Map<String, dynamic> && data.containsKey('orders')) {
        final list = data['orders'] as List;
        return list.map((e) => OrderModel.fromJson(e)).toList();
      }
      
      // Dự phòng trường hợp API vẫn trả về mảng trực tiếp
      if (data is List) {
        return data.map((e) => OrderModel.fromJson(e)).toList();
      }
      
      throw const ServerException('Dữ liệu đơn hàng không hợp lệ');
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi tải đơn hàng');
    }
  }
}
