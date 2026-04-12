import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/review_model.dart';

@Injectable(as: ReviewRepository)
class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<AppReview>>> getReviewsByProduct(
      String productId) async {
    try {
      final models = await remoteDataSource.getReviewsByProduct(productId);
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, AppReview>> submitReview(
      String productId, int rating, String comment) async {
    try {
      final model = await remoteDataSource.submitReview(productId, rating, comment);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Lỗi không xác định'));
    }
  }
}
