import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_review.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

@freezed
class ReviewUserModel with _$ReviewUserModel {
  const factory ReviewUserModel({
    @JsonKey(name: '_id') required String id,
    @Default('User') String name,
    String? avatar,
  }) = _ReviewUserModel;

  factory ReviewUserModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewUserModelFromJson(json);
}

@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    @JsonKey(name: '_id') required String id,
    required ReviewUserModel user,
    @JsonKey(name: 'product') required String productId,
    required int rating,
    @Default('') String comment,
    required DateTime createdAt,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);
}

extension ReviewModelX on ReviewModel {
  AppReview toEntity() => AppReview(
        id: id,
        userId: user.id,
        userName: user.name,
        userAvatar: user.avatar,
        productId: productId,
        rating: rating,
        comment: comment,
        createdAt: createdAt,
      );
}
