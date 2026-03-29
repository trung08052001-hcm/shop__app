import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class AppOrder extends Equatable {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  const AppOrder({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, status];
}
