import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

@injectable
class GetOrdersUseCase extends UseCase<List<AppOrder>, NoParams> {
  final OrderRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppOrder>>> call(NoParams params) {
    return repository.getMyOrders();
  }
}
