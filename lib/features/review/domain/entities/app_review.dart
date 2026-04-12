import 'package:equatable/equatable.dart';

class AppReview extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String productId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const AppReview({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        productId,
        rating,
        comment,
        createdAt,
      ];
}
