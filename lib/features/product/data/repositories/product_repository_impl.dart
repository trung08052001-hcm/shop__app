import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/features/product/data/models/product_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';

@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  ProductRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? category,
    String? search,
    int page = 1,
  }) async {
    try {
      final models = await remoteDataSource.getProducts(
        category: category,
        search: search,
        page: page,
      );
      // Cache the products if it is the first page without search filters
      if (page == 1 && search == null && category == null) {
        await localDataSource.cacheProducts(models);
      }
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      // If fetching fails, try getting cached products
      try {
        final cachedModels = await localDataSource.getCachedProducts();
        if (cachedModels.isNotEmpty) {
          // Filter cached models if needed (optional)
          var filteredModels = cachedModels;
          if (category != null) {
            filteredModels = filteredModels.where((element) => element.category == category).toList();
          }
          if (search != null) {
            filteredModels = filteredModels.where((element) => element.name.toLowerCase().contains(search.toLowerCase())).toList();
          }
          return Right(filteredModels.map((e) => e.toEntity()).toList());
        }
      } catch (_) {
        // Fallback to error
      }
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      }
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final model = await remoteDataSource.getProductById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(categories);
      return Right(categories);
    } catch (e) {
      try {
        final cachedCategories = await localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return Right(cachedCategories);
        }
      } catch (_) {}
      if (e is ServerException) {
        return Left(ServerFailure(e.message));
      }
      return Left(const NetworkFailure());
    }
  }
}
