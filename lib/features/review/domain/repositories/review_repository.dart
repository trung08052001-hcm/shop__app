import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<AppReview>>> getReviewsByProduct(String productId);
  Future<Either<Failure, AppReview>> submitReview(
      String productId, int rating, String comment);
}
