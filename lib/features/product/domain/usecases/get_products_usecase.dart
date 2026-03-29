import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@injectable
class GetProductsUseCase extends UseCase<List<Product>, GetProductsParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) {
    return repository.getProducts(
      category: params.category,
      search: params.search,
      page: params.page,
    );
  }
}

class GetProductsParams extends Equatable {
  final String? category;
  final String? search;
  final int page;

  const GetProductsParams({this.category, this.search, this.page = 1});

  @override
  List<Object?> get props => [category, search, page];
}
