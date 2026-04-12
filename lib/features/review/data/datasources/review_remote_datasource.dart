import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviewsByProduct(String productId);
  Future<ReviewModel> submitReview(String productId, int rating, String comment);
}

@Injectable(as: ReviewRemoteDataSource)
class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient dioClient;

  ReviewRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ReviewModel>> getReviewsByProduct(String productId) async {
    try {
      final response = await dioClient.dio.get('/reviews/product/$productId');
      final list = response.data as List;
      return list.map((e) => ReviewModel.fromJson(e)).toList();
    } catch (e) {
      throw const ServerException('Không tải được đánh giá sản phẩm');
    }
  }

  @override
  Future<ReviewModel> submitReview(
      String productId, int rating, String comment) async {
    try {
      final response = await dioClient.dio.post('/reviews', data: {
        'product': productId,
        'rating': rating,
        'comment': comment,
      });
      return ReviewModel.fromJson(response.data['review']);
    } catch (e) {
      throw const ServerException('Không thể gửi đánh giá');
    }
  }
}
