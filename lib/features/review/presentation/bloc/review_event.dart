part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductReviews extends ReviewEvent {
  final String productId;

  const LoadProductReviews(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SubmitReviewEvent extends ReviewEvent {
  final String productId;
  final int rating;
  final String comment;

  const SubmitReviewEvent({
    required this.productId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [productId, rating, comment];
}
