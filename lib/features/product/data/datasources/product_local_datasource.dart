import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_app/features/product/data/models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<String>> getCachedCategories();
  Future<void> cacheCategories(List<String> categories);
}

@LazySingleton(as: ProductLocalDataSource)
class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _productsBoxName = 'products_box';
  static const String _categoriesBoxName = 'categories_box';

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final box = await Hive.openBox(_productsBoxName);
    final productsJson = box.get('products') as String?;
    if (productsJson != null) {
      final List decoded = jsonDecode(productsJson);
      return decoded.map((e) => ProductModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = await Hive.openBox(_productsBoxName);
    final productsJson = jsonEncode(products.map((e) => e.toJson()).toList());
    await box.put('products', productsJson);
  }

  @override
  Future<List<String>> getCachedCategories() async {
    final box = await Hive.openBox(_categoriesBoxName);
    final categories = box.get('categories') as List?;
    if (categories != null) {
      return List<String>.from(categories);
    }
    return [];
  }

  @override
  Future<void> cacheCategories(List<String> categories) async {
    final box = await Hive.openBox(_categoriesBoxName);
    await box.put('categories', categories);
  }
}
