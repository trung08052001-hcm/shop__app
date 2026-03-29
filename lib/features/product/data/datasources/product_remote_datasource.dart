import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
  });
  Future<ProductModel> getProductById(String id);
  Future<List<String>> getCategories();
}

@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;
  ProductRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    int page = 1,
  }) async {
    try {
      final res = await dioClient.dio.get(
        '/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          'page': page,
        },
      );
      final list = res.data['products'] as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi tải sản phẩm');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final res = await dioClient.dio.get('/products/$id');
      return ProductModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi tải sản phẩm');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final res = await dioClient.dio.get('/products/categories');
      return List<String>.from(res.data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data?['message'] ?? 'Lỗi tải danh mục');
    }
  }
}
