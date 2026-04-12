import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_review.dart';
import '../../domain/repositories/review_repository.dart';

part 'review_event.dart';
part 'review_state.dart';

@injectable
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc(this.repository) : super(ReviewInitial()) {
    on<LoadProductReviews>(_onLoadProductReviews);
    on<SubmitReviewEvent>(_onSubmitReview);
  }

  Future<void> _onLoadProductReviews(
      LoadProductReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    final result = await repository.getReviewsByProduct(event.productId);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewLoaded(reviews)),
    );
  }

  Future<void> _onSubmitReview(
      SubmitReviewEvent event, Emitter<ReviewState> emit) async {
    emit(ReviewSubmitLoading());
    final result = await repository.submitReview(
        event.productId, event.rating, event.comment);
    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewSubmittedSuccess(review)),
    );
  }
}
