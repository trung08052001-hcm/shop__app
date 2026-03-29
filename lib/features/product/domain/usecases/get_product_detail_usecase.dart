import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProductDetailUseCase extends UseCase<Product, String> {
  final ProductRepository repository;
  GetProductDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(String id) {
    return repository.getProductById(id);
  }
}
