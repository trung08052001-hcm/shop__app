import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/core/usecases/usecases.dart';
import '../../../../core/error/failures.dart';
import '../repositories/product_repository.dart';

@injectable
class GetCategoriesUseCase extends UseCase<List<String>, NoParams> {
  final ProductRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return repository.getCategories();
  }
}
