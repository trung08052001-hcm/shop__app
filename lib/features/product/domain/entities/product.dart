import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final int stock;
  final double rating;
  final int numReviews;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.stock,
    required this.rating,
    required this.numReviews,
  });

  @override
  List<Object?> get props => [id, name, price, image, category, stock, rating];
}
