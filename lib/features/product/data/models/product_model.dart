import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String description,
    required double price,
    required String image,
    required String category,
    required int stock,
    @Default(0.0) double rating,
    @Default(0) int numReviews,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

extension ProductModelX on ProductModel {
  Product toEntity() => Product(
    id: id,
    name: name,
    description: description,
    price: price,
    image: image,
    category: category,
    stock: stock,
    rating: rating,
    numReviews: numReviews,
  );
}
