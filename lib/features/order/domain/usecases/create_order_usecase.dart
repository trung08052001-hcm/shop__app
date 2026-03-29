import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';

import '../entities/order.dart' hide Order;
import '../repositories/order_repository.dart';

@injectable
class CreateOrderUseCase extends UseCase<AppOrder, CreateOrderParams> {
  final OrderRepository repository;
  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, AppOrder>> call(CreateOrderParams params) {
    return repository.createOrder(
      items: params.items,
      totalPrice: params.totalPrice,
    );
  }
}

class CreateOrderParams extends Equatable {
  final List<OrderItem> items;
  final double totalPrice;

  const CreateOrderParams({required this.items, required this.totalPrice});

  @override
  List<Object?> get props => [items, totalPrice];
}
