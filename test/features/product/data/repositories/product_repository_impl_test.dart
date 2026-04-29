import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shop_app/core/error/exceptions.dart';
import 'package:shop_app/features/product/data/datasources/product_local_datasource.dart';
import 'package:shop_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:shop_app/features/product/data/models/product_model.dart';
import 'package:shop_app/features/product/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock implements ProductRemoteDataSource {}
class MockProductLocalDataSource extends Mock implements ProductLocalDataSource {}

void main() {
  late MockProductRemoteDataSource mockRemoteDataSource;
  late MockProductLocalDataSource mockLocalDataSource;
  late ProductRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    mockLocalDataSource = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('getProducts', () {
    const tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Desc',
      price: 100.0,
      image: 'image.png',
      category: 'Category',
      stock: 10,
    );

    test('should return remote data when the call to remote data source is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getProducts(
        page: any(named: 'page'),
        category: any(named: 'category'),
        search: any(named: 'search'),
      )).thenAnswer((_) async => [tProductModel]);
      when(() => mockLocalDataSource.cacheProducts(any()))
          .thenAnswer((_) async {});

      // act
      final result = await repository.getProducts(page: 1);

      // assert
      verify(() => mockRemoteDataSource.getProducts(page: 1)).called(1);
      verify(() => mockLocalDataSource.cacheProducts([tProductModel])).called(1);
      expect(result.isRight(), true);
    });

    test('should return cached data when remote call fails and cache exists', () async {
      // arrange
      when(() => mockRemoteDataSource.getProducts(
        page: any(named: 'page'),
        category: any(named: 'category'),
        search: any(named: 'search'),
      )).thenThrow(ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedProducts())
          .thenAnswer((_) async => [tProductModel]);

      // act
      final result = await repository.getProducts(page: 1);

      // assert
      verify(() => mockRemoteDataSource.getProducts(page: 1)).called(1);
      verify(() => mockLocalDataSource.getCachedProducts()).called(1);
      expect(result.isRight(), true);
    });
  });
}
