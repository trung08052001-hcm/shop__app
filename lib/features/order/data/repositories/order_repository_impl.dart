import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/features/order/data/models/order_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

@Injectable(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AppOrder>> createOrder({
    required List<OrderItem> items,
    required double totalPrice,
  }) async {
    try {
      final model = await remoteDataSource.createOrder(
        items: items,
        totalPrice: totalPrice,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(const NetworkFailure());
    } on UnauthorizedException {
      return Left(const UnauthorizedFailure());
    } catch (_) {
      return Left(const ServerFailure('Có lỗi xảy ra'));
    }
  }

  @override
  Future<Either<Failure, List<AppOrder>>> getMyOrders() async {
    try {
      final models = await remoteDataSource.getMyOrders();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(const NetworkFailure());
    } on UnauthorizedException {
      return Left(const UnauthorizedFailure());
    } catch (_) {
      return Left(const ServerFailure('Có lỗi xảy ra'));
    }
  }
}
