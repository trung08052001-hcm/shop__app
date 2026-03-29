import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../features/product/domain/entities/product.dart';

@singleton
class WishlistService {
  static const _boxName = 'wishlist';

  Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  Future<void> add(Product product) async {
    final box = await _getBox();
    await box.put(product.id, {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'category': product.category,
      'description': product.description,
      'stock': product.stock,
      'rating': product.rating,
      'numReviews': product.numReviews,
    });
  }

  Future<void> remove(String productId) async {
    final box = await _getBox();
    await box.delete(productId);
  }

  Future<bool> isWishlisted(String productId) async {
    final box = await _getBox();
    return box.containsKey(productId);
  }

  Future<List<Product>> getAll() async {
    final box = await _getBox();
    return box.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Product(
        id: map['id'],
        name: map['name'],
        price: (map['price'] as num).toDouble(),
        image: map['image'],
        category: map['category'],
        description: map['description'],
        stock: map['stock'],
        rating: (map['rating'] as num).toDouble(),
        numReviews: map['numReviews'],
      );
    }).toList();
  }

  Future<void> toggle(Product product) async {
    final wishlisted = await isWishlisted(product.id);
    if (wishlisted) {
      await remove(product.id);
    } else {
      await add(product);
    }
  }
}
