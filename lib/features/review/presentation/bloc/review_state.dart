part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<AppReview> reviews;

  const ReviewLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReviewSubmitLoading extends ReviewState {}

class ReviewSubmittedSuccess extends ReviewState {
  final AppReview review;

  const ReviewSubmittedSuccess(this.review);

  @override
  List<Object?> get props => [review];
}
