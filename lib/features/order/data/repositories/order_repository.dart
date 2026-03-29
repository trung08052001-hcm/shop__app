import 'package:dartz/dartz.dart';
import 'package:shop_app/features/order/domain/entities/order.dart';
import '../../../../core/error/failures.dart';

abstract class OrderRepository {
  Future<Either<Failure, AppOrder>> createOrder({
    required List<OrderItem> items,
    required double totalPrice,
  });

  Future<Either<Failure, List<AppOrder>>> getMyOrders();
}
