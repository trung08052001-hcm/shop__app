import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/error/exceptions.dart';
import 'package:shop_app/features/review/data/datasources/review_remote_datasource.dart';
import 'package:shop_app/features/review/data/models/review_model.dart';
import 'package:shop_app/features/review/data/repositories/review_repository_impl.dart';

class MockReviewRemoteDataSource extends Mock implements ReviewRemoteDataSource {}

void main() {
  late MockReviewRemoteDataSource mockRemoteDataSource;
  late ReviewRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockReviewRemoteDataSource();
    repository = ReviewRepositoryImpl(mockRemoteDataSource);
  });

  group('submitReview', () {
    final tReviewModel = ReviewModel(
      id: 'r1',
      productId: 'p1',
      user: const ReviewUserModel(id: 'u1', name: 'Test User'),
      rating: 5,
      comment: 'Excellent product!',
      createdAt: DateTime(2026, 4, 29),
    );

    test('should return review when the call to remote data source is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.submitReview(any(), any(), any()))
          .thenAnswer((_) async => tReviewModel);

      // act
      final result = await repository.submitReview('p1', 5, 'Excellent product!');

      // assert
      verify(() => mockRemoteDataSource.submitReview('p1', 5, 'Excellent product!')).called(1);
      expect(result.isRight(), true);
      
      // Check data inside Right
      result.fold(
        (failure) => fail('Should not be left'),
        (review) {
          expect(review.id, 'r1');
          expect(review.rating, 5);
          expect(review.comment, 'Excellent product!');
        }
      );
    });

    test('should return ServerFailure when the call to remote data source fails', () async {
      // arrange
      when(() => mockRemoteDataSource.submitReview(any(), any(), any()))
          .thenThrow(ServerException('Server error'));

      // act
      final result = await repository.submitReview('p1', 5, 'Excellent product!');

      // assert
      verify(() => mockRemoteDataSource.submitReview('p1', 5, 'Excellent product!')).called(1);
      expect(result.isLeft(), true);
    });
  });
}
